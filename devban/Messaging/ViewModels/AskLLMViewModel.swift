import FoundationModels
import SwiftUI

/// ViewModel for AskLLM.
@Observable
final class AskLLMViewModel
{
    init()
    {
        session = LanguageModelSession()
        messages = [
            AskLLMViewModel.getGreetingMessage(),
        ]
    }

    private var session: LanguageModelSession
    private(set) var messages: [ChatMessage]
    var userInput: String = ""
    var userInputSelectedRange = NSRange(location: 0, length: 0)

    private(set) var isThinking: Bool = false
    private(set) var isResponding: Bool = false
    private(set) var LLMStreamingContent: String.PartiallyGenerated?
    private var streamingTask: Task<Void, Never>?

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
        guard !(isThinking || isResponding) else { return }
        guard !userInput.isEmptyOrWhitespace() else { return }

        isThinking = true

        messages.append(
            ChatMessage(senderID: DevbanUser.shared.uid, content: userInput),
        )
        let msgContent: String = userInput
        userInput = ""

        streamingTask = Task
        {
            do
            {
                let stream = session.streamResponse(to: msgContent)

                for try await partial in stream
                {
                    isThinking = false
                    isResponding = true

                    if (LLMStreamingContent == nil)
                    {
                        LLMStreamingContent = ""
                    }

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
                            try await Task.sleep(nanoseconds: 1_000_000) // 1 ms
                        }
                    }
                    else
                    {
                        LLMStreamingContent = partial.content
                    }
                }

                guard !Task.isCancelled else { return }

                storeLLMOutputToMessages()

                isThinking = false
                isResponding = false
                LLMStreamingContent = nil
                streamingTask = nil
            }
            catch
            {
                print("AskLLM Error: \(error)")

                isThinking = false
                isResponding = false
                LLMStreamingContent = nil
                streamingTask = nil

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
            }
        }
    }

    func stopModel()
    {
        isThinking = false
        isResponding = false

        streamingTask?.cancel()
        streamingTask = nil

        if let LLMStreamingContent,
           !LLMStreamingContent.isEmptyOrWhitespace()
        {
            storeLLMOutputToMessages()
        }

        LLMStreamingContent = nil
    }

    func clearContext()
    {
        if (isThinking || isResponding)
        {
            storeLLMOutputToMessages()
            resetModel()
        }

        guard !messages.isEmpty else { return }
        messages[messages.count - 1].LLMContextClearedAfter = true
    }

    func restart()
    {
        resetModel()
        messages = [
            AskLLMViewModel.getGreetingMessage(),
        ]
    }

    private func storeLLMOutputToMessages()
    {
        messages.append(
            ChatMessage(
                senderID: nil,
                content: LLMStreamingContent ?? "",
            ),
        )
    }

    private func resetModel()
    {
        isThinking = false
        isResponding = false

        streamingTask?.cancel()
        streamingTask = nil

        session = LanguageModelSession()
        LLMStreamingContent = nil
    }
}
