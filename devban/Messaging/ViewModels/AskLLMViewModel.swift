import FoundationModels
import SwiftUI

/// ViewModel for AskLLM.
@Observable
final class AskLLMViewModel
{
    init()
    {
        resetStreamingTask()
        messages = [
            AskLLMViewModel.getGreetingMessage(),
        ]
    }

    private var session: LanguageModelSession = LanguageModelSession()
    private(set) var messages: [ChatMessage] = []
    var userInput: String = ""
    var userInputSelectedRange = NSRange(location: 0, length: 0)

    private(set) var responseStatus: ResponseStatus = .idle
    private(set) var LLMStreamingContent: String.PartiallyGenerated?
    private var streamingTask: Task<Void, Never>?

    func resetSession()
    {
        resetStreamingTask()
        session = LanguageModelSession()
        messages = [
            AskLLMViewModel.getGreetingMessage(),
        ]
    }

    static func getGreetingMessage() -> ChatMessage
    {
        switch SystemLanguageModel.default.availability
        {
            case .available:
                return ChatMessage(
                    senderID: nil,
                    content: "Hello! How may I assist you today?",
                )
            case .unavailable(.deviceNotEligible):
                return ChatMessage(
                    senderID: nil,
                    content: "Error: Your device is not eligible for Apple Intelligence.",
                )
            case .unavailable(.appleIntelligenceNotEnabled):
                return ChatMessage(
                    senderID: nil,
                    content: "Error: To use this feature, please turn on Apple Intelligence.",
                )
            case .unavailable(.modelNotReady):
                return ChatMessage(
                    senderID: nil,
                    content: "Error: Model is not ready. Please try again later.",
                )
            case _:
                return ChatMessage(
                    senderID: nil,
                    content: "Error: Apple Intelligence / LLM model is unavailable for unknown reason.",
                )
        }
    }

    func sendMessage()
    {
        guard (responseStatus == .idle), // For askLLM only
              (!userInput.isEmptyOrWhitespace()),
              let user = DevbanUserContainer.shared.user
        else
        {
            return
        }

        let trimmed: String = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        messages.append(
            ChatMessage(senderID: user.uid, content: trimmed),
        )
        let prompt: String = userInput
        userInput = ""

        // Get response from LLM
        promptLLM(prompt)
    }

    private func promptLLM(_ prompt: String)
    {
        guard (responseStatus == .idle) else { return }

        responseStatus = .thinking

        // Cancel any existing streaming task before starting a new one
        streamingTask?.cancel()
        streamingTask = Task
        {
            do
            {
                let stream = session.streamResponse(to: prompt)
                LLMStreamingContent = ""

                for try await partial in stream
                {
                    responseStatus = .responding

                    let originalLength: Int = LLMStreamingContent?.count ?? 0

                    // When the message is short, render character by character.
                    // When it is long, render chunk by chunk to prevent lag.
                    if (originalLength < 500)
                    {
                        // Get only the new characters since last update
                        let newContent = partial.content
                        let newCharacters = String(newContent.dropFirst(originalLength))

                        // Append character by character with small delay so that the display look smooth
                        for character in newCharacters
                        {
                            LLMStreamingContent?.append(character)
                            try await Task.sleep(nanoseconds: 100_000) // 0.1 ms
                        }
                    }
                    else
                    {
                        LLMStreamingContent = partial.content
                    }
                }

                storeLLMOutputToMessages()

                // Cancel task is set to false because
                // 1. The task is already completed successfully at this point.
                // 2. It is better not to cancel the task within the task itself.
                resetStreamingTask(cancelTask: false)
            }
            catch
            {
                // There may be some output before the error occurred
                storeLLMOutputToMessages()

                print("AskLLM Error: \(error)")

                // Ignores CancellationError as it is requested by User (i.e. expected behaviour)
                if !(error is CancellationError)
                {
                    messages.append(
                        ChatMessage(
                            senderID: nil,
                            content: "Error: \(error.localizedDescription)",
                        ),
                    )
                }

                // Cancel task is set to false because
                // 1. The task is already completed successfully at this point.
                // 2. It is better not to cancel the task within the task itself.
                resetStreamingTask(cancelTask: false)
            }
        }
    }

    func stopModel()
    {
        storeLLMOutputToMessages()
        resetStreamingTask()
    }

    func clearContext()
    {
        stopModel()
        session = LanguageModelSession()

        guard !messages.isEmpty else { return }
        messages[messages.count - 1].LLMContextClearedAfter = true
    }

    private func resetStreamingTask(cancelTask: Bool = true)
    {
        if (cancelTask)
        {
            streamingTask?.cancel()
        }
        streamingTask = nil
        LLMStreamingContent = nil

        responseStatus = .idle
    }

    private func storeLLMOutputToMessages()
    {
        if let LLMStreamingContent,
           !LLMStreamingContent.isEmptyOrWhitespace()
        {
            let trimmed: String = LLMStreamingContent.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }

            messages.append(
                ChatMessage(
                    senderID: nil,
                    content: trimmed,
                ),
            )
        }
    }
}
