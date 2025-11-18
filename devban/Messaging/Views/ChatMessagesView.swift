import FoundationModels
import SwiftUI

/// A SwiftUI view that renders chat messages.
///
/// - Parameters:
///     - messages: The messages to be rendered.
///     - responseStatus: Response status of the sender.
///     - LLMStreamingContent: Partial content streamed from LLM output.
///     - userInput: Partial user input for preview.
struct ChatMessagesView: View
{
    let messages: [ChatMessage]
    let responseStatus: ResponseStatus
    let LLMStreamingContent: String
    let userInput: String?

    @Namespace var bottomElement

    var body: some View
    {
        ScrollViewReader
        { proxy in
            ScrollView
            {
                LazyVStack(alignment: .leading, spacing: 12)
                {
                    // MARK: Render all message records

                    ForEach(messages)
                    { msg in
                        if (msg.messageType != .assistantContextClear)
                        {
                            ChatBubbleView(msg)
                        }
                        else
                        {
                            VStack(spacing: 5)
                            {
                                Divider()

                                Text("Context Cleared")
                                    .foregroundColor(.gray)

                                Divider()
                            }
                        }
                    }

                    // MARK: Render partial content streamed from LLM output.

                    if (responseStatus == .thinking)
                    {
                        ProgressView()
                    }
                    else if !LLMStreamingContent.isEmptyOrWhitespace()
                    {
                        let trimmed: String = LLMStreamingContent.trimmingCharacters(in: .whitespacesAndNewlines)
                        ChatBubbleView(
                            ChatMessage(
                                senderID: nil,
                                content: trimmed,
                                messageType: .assistantResponse,
                            ),
                        )
                    }

                    // MARK: Render user input preview.

                    if let userInput,
                       !userInput.isEmptyOrWhitespace(),
                       let uid = DevbanUserContainer.shared.getUid()
                    {
                        let trimmed: String = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
                        ChatBubbleView(
                            ChatMessage(
                                senderID: uid,
                                content: trimmed,
                                messageType: .user,
                            ),
                        )
                    }

                    // MARK: Invisible element for scrolling purpose.

                    Color.clear
                        .frame(height: 1)
                        .id(bottomElement)
                }
                .padding()
            }
            // Scroll to bottom when initialized
            .onAppear
            {
                proxy.scrollTo(bottomElement)
            }
        }
    }
}
