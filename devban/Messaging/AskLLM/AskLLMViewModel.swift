import SwiftUI

extension AskLLMView
{
    /// ViewModel for AskLLM.
    @Observable
    final class AskLLMViewModel
    {
        init()
        {
            messages = [
                ChatMessage(
                    senderID: nil,
                    content: "Hello! How may I assist you today?",
                    messageType: .assistantGreeting,
                ),
            ]
        }

        var userInput: String = ""
        var userInputSelectedRange = NSRange(location: 0, length: 0)

        private(set) var messages: [ChatMessage] = []
        private(set) var model: AppleIntelligence = .init()
        private(set) var streamingContent: String = ""

        var disableSubmit: Bool
        {
            return model.responseStatus != .idle || userInput.isEmptyOrWhitespace()
        }

        func sendMessage()
        {
            guard !disableSubmit,
                  let uid = DevbanUserContainer.shared.getUid()
            else
            {
                return
            }

            let trimmed: String = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }

            messages.append(
                ChatMessage(senderID: uid, content: trimmed, messageType: .user),
            )
            userInput = ""

            // Get response from LLM
            promptLLM(trimmed)
        }

        private func promptLLM(_ prompt: String)
        {
            self.streamingContent = ""
            model.prompt(prompt)
            { partialContent in
                let previousOutputLength: Int = self.streamingContent.count

                // When the message is short, render character by character.
                // When it is long, render chunk by chunk to prevent lag.
                if (previousOutputLength < 500)
                {
                    // Get only the new characters since last update
                    let newCharacters = String(partialContent.dropFirst(previousOutputLength))

                    // Append character by character with small delay so that the display look smooth
                    for character in newCharacters
                    {
                        self.streamingContent.append(character)
                        do
                        {
                            try await Task.sleep(nanoseconds: 100_000) // 0.1 ms
                        }
                        catch
                        {
                            print(error.localizedDescription)
                        }
                    }
                }
                else
                {
                    self.streamingContent = partialContent
                }
            }
            onFinish:
            {
                self.messages.append(
                    ChatMessage(
                        senderID: nil,
                        content: self.streamingContent.trimmingCharacters(in: .whitespacesAndNewlines),
                        messageType: .assistantResponse,
                    ),
                )
                self.streamingContent = ""
            }
            onError:
            { error in
                if (!self.streamingContent.isEmptyOrWhitespace())
                {
                    self.messages.append(
                        ChatMessage(
                            senderID: nil,
                            content: self.streamingContent.trimmingCharacters(in: .whitespacesAndNewlines),
                            messageType: .assistantResponse,
                        ),
                    )
                    self.streamingContent = ""
                }
                print("Error detected: \(error.localizedDescription)")
                self.messages.append(
                    ChatMessage(
                        senderID: nil,
                        content: "Error: \(error.localizedDescription)",
                        messageType: .system,
                    ),
                )
            }
        }

        func resetSession()
        {
            model.stopSession()

            Task
            {
                await waitForIdle()
                model.resetSession()
                await MainActor.run
                {
                    messages = [
                        ChatMessage(
                            senderID: nil,
                            content: "Hello! How may I assist you today?",
                            messageType: .assistantGreeting,
                        ),
                    ]
                }
            }
        }

        func stopModel()
        {
            model.stopSession()
        }

        func clearContext()
        {
            model.stopSession()

            Task
            {
                await waitForIdle()
                model.resetSession()
                await MainActor.run
                {
                    messages.append(
                        ChatMessage(
                            senderID: nil,
                            content: "",
                            messageType: .assistantContextClear,
                        ),
                    )
                }
            }
        }

        private func waitForIdle(timeoutSeconds: TimeInterval = 5.0) async
        {
            let timeoutNanoseconds = UInt64(timeoutSeconds * 1_000_000_000)
            let checkInterval: UInt64 = 100_000_000 // 0.1 seconds
            var elapsed: UInt64 = 0

            while (model.responseStatus != .idle), (elapsed < timeoutNanoseconds)
            {
                try? await Task.sleep(nanoseconds: checkInterval)
                elapsed += checkInterval
            }
        }
    }
}
