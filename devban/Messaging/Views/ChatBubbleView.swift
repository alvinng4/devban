import SwiftUI

/// A SwiftUI view that renders a single chat bubble.
///
/// The bubble is right-aligned for messages from the current user and
/// left-aligned for messages from others. Background color reflects
/// whether the message is from the current user.
///
/// - Parameter chatMessage: The message to render in the bubble.
struct ChatBubbleView: View
{
    init(_ chatMessage: ChatMessage)
    {
        self.chatMessage = chatMessage

        // TODO: After User is implemented, verify whether senderID equals to current user
        // Currently: Since we are only talking with LLM, we know it is LLM when senderID is nil.
        isCurrentUser = (chatMessage.senderID != nil)
    }

    let chatMessage: ChatMessage
    let isCurrentUser: Bool

    var backgroundColor: Color
    {
        if (isCurrentUser)
        {
            return ThemeManager.shared.backgroundColor
        }
        return Color.gray.opacity(0.3)
    }

    var body: some View
    {
        Text(chatMessage.content)
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .padding(isCurrentUser ? .leading : .trailing, 20)
            .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
    }
}
