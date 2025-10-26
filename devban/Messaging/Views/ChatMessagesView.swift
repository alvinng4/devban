import FoundationModels
import SwiftUI

struct ChatMessagesView: View
{
    let messages: [ChatMessage]
    let isLoading: Bool
    let partialLLMMessage: String?

    @Namespace var bottomElement

    var body: some View
    {
        ScrollViewReader
        { proxy in
            ScrollView
            {
                LazyVStack(alignment: .leading, spacing: 12)
                {
                    ForEach(messages)
                    { msg in
                        ChatBubbleView(msg)
                    }

                    if let partialLLMMessage
                    {
                        ChatBubbleView(
                            ChatMessage(
                                senderID: nil,
                                content: partialLLMMessage,
                            ),
                        )
                        .animation(.easeInOut(duration: 0.2), value: partialLLMMessage)
                    }
                    else if (isLoading)
                    {
                        ProgressView()
                    }

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
