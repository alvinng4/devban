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

        if let uid = DevbanUserContainer.shared.getUid()
        {
            isCurrentUser = (chatMessage.senderId == uid && chatMessage.messageType == .user)
        }
        else
        {
            isCurrentUser = false
        }
    }

    @Environment(\.colorScheme) private var colorScheme

    private let chatMessage: ChatMessage
    private let isCurrentUser: Bool
    @State private var displayName: String?
    private let theme: Splash.Theme = .wwdc17(withFont: .init(size: 16))

    private var backgroundColor: SwiftUI.Color
    {
        if (isCurrentUser)
        {
            return ThemeManager.shared.backgroundColor
        }
        return Color.gray.opacity(0.3)
    }

    func loadDisplayName() async throws -> String?
    {
        switch (chatMessage.messageType)
        {
            case .user:
                try await DevbanUser.getDisplayName(chatMessage.senderId)
            case .assistantGreeting:
                "Apple Intelligence"
            case .assistantResponse:
                "Apple Intelligence"
            case .assistantContextClear:
                nil
            case .system:
                "System"
        }
    }

    var body: some View
    {
        VStack(spacing: 0)
        {
            if let displayName
            {
                Text(displayName)
                    .foregroundStyle(.tertiary)
                    .font(.footnote)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
                    .padding(.horizontal, 2)
            }

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

            Text(chatMessage.sentDate.formatted(date: .abbreviated, time: .shortened))
                .foregroundStyle(.tertiary)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
                .padding(.horizontal, 2)
        }
        .task
        {
            do
            {
                displayName = try await loadDisplayName()
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }

    @ViewBuilder
    private func codeBlock(_ configuration: CodeBlockConfiguration) -> some View
    {
        /// Get the name of the language
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
            // MARK: Tool bar showing the language name and copy button

            HStack
            {
                Text(language)
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(theme.plainTextColor))

                Spacer()

                Button
                {
                    TextEditingHelper.copyToClipboard(configuration.content)
                }
                label:
                {
                    Image(systemName: "document.on.document")
                        .textEditorToolBarButtonImage()
                        .foregroundStyle(.gray)
                        .padding(4)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(theme.backgroundColor))

            Divider()

            // MARK: Showing the acutal code content

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
