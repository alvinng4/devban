import FoundationModels
import SwiftUI

/// A SwiftUI view that renders chat messages.
///
/// - Parameters:
///     - messages: The messages to be rendered.
///     - isLoading: Boolean variable to indicate whether the opponent message is loading.
///     - LLMStreamingContent: Partial content streamed from LLM output.
///     - userInput: Partial user input for preview.
struct ChatMessagesView: View
{
    let messages: [ChatMessage]
    let isLoading: Bool
    let LLMStreamingContent: String.PartiallyGenerated?
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
                        ChatBubbleView(msg)
                    }

                    // MARK: Render partial content streamed from LLM output.

                    if let LLMStreamingContent
                    {
                        ChatBubbleView(
                            ChatMessage(
                                senderID: nil,
                                content: LLMStreamingContent,
                            ),
                        )
                    }
                    else if (isLoading)
                    {
                        ProgressView()
                    }

                    // MARK: Render user input preview.

                    if let userInput,
                       !userInput.isEmptyOrWhitespace()
                    {
                        // TODO: After User is implemented, change senderID to actual user id
                        ChatBubbleView(
                            ChatMessage(
                                senderID: UUID(),
                                content: userInput,
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
