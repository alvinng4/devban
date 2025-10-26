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
            ChatMessage(senderID: nil, content: AskLLMViewModel.defaultGreeting),
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

    static let defaultGreeting: String = "Hello! How may I assist you today?"

    func sendMessage()
    {
        guard !(isThinking || isResponding) else { return }
        guard !userInput.isEmptyOrWhitespace() else { return }

        isThinking = true

        // TODO: Change the senderID to actual user ID after User is implemented
        messages.append(
            ChatMessage(senderID: UUID(), content: userInput),
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
                            try await Task.sleep(nanoseconds: 1_000_000) // 5 ms
                        }
                    }
                    else
                    {
                        LLMStreamingContent = partial.content
                    }
                }

                guard !Task.isCancelled else { return }

                messages.append(
                    ChatMessage(
                        senderID: nil,
                        content: LLMStreamingContent ?? "",
                    ),
                )

                isResponding = false
                LLMStreamingContent = nil
                streamingTask = nil
            }
            catch
            {
                print("AskLLM Error: \(error)")
                messages.append(
                    ChatMessage(
                        senderID: nil,
                        content: "Error: \(error.localizedDescription)",
                    ),
                )

                isThinking = false
                isResponding = false
                LLMStreamingContent = nil
                streamingTask = nil
            }
        }
    }
}
