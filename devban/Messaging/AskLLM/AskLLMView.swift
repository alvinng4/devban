import FoundationModels
import SwiftUI

struct AskLLMView: View
{
    static let defaultGreeting: String = "Hello! How may I assist you today?"
    static let prompt: String = "Please show me the code for Hello, world in Python. Also show me the output in Python interpreter."

    @State private var displayText: String?

    var body: some View
    {
        ZStack
        {
            ThemeManager.shared.backgroundColor

            VStack(spacing: 0)
            {
                // TODO: Change the senderID to actual user ID after User is implemented
                ChatMessagesView(
                    messages: [
                        ChatMessage(senderID: nil, content: AskLLMView.defaultGreeting),
                        ChatMessage(senderID: UUID(), content: AskLLMView.prompt),
                    ],
                    isLoading: false,
                    partialLLMMessage: displayText,
                )

                Divider()

                Text("Test")
            }
            .shadowedBorderRoundedRectangle()
            .padding()
        }
        .onAppear
        {
            Task
            {
                await streamResponse()
            }
        }
    }

    private func streamResponse() async
    {
        let stream = LanguageModelSession().streamResponse(to: AskLLMView.prompt)

        do
        {
            for try await partial in stream
            {
                await MainActor.run
                {
                    displayText = partial.content
                }
            }
        }
        catch
        {
            print("Streaming error: \(error)")
        }
    }
}
