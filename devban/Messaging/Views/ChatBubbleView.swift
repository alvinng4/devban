import MarkdownUI
import Splash
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

    @Environment(\.colorScheme) private var colorScheme

    private let chatMessage: ChatMessage
    private let isCurrentUser: Bool
    private let theme: Splash.Theme = .wwdc17(withFont: .init(size: 16))

    private var backgroundColor: SwiftUI.Color
    {
        if (isCurrentUser)
        {
            return ThemeManager.shared.backgroundColor
        }
        return Color.gray.opacity(0.3)
    }

    var body: some View
    {
        Markdown(chatMessage.content)
            .markdownBlockStyle(\.codeBlock)
            {
                codeBlock($0)
            }
            .markdownCodeSyntaxHighlighter(.splash(theme: theme))
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .padding(isCurrentUser ? .leading : .trailing, 20)
            .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
    }

    @ViewBuilder
    private func codeBlock(_ configuration: CodeBlockConfiguration) -> some View
    {
        var language: String
        {
            if let lang = configuration.language,
               !lang.isEmptyOrWhitespace()
            {
                return lang
            }

            return "plain text"
        }

        VStack(spacing: 0)
        {
            HStack
            {
                Text(language)
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(theme.plainTextColor))

                Spacer()

                Button
                {
                    // TODO: Implement copy to clipboard
//                    copyToClipboard(configuration.content)
                }
                label:
                {
                    Image(systemName: "clipboard")
                        .foregroundStyle(.gray)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1),
                )
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(theme.backgroundColor))

            Divider()

            ScrollView(.horizontal)
            {
                configuration.label
                    .relativeLineSpacing(.em(0.25))
                    .markdownTextStyle
                    {
                        FontFamilyVariant(.monospaced)
                        FontSize(.em(0.85))
                    }
                    .padding()
            }
        }
        .background(.darkBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .markdownMargin(top: .zero, bottom: .em(0.8))
    }
}
