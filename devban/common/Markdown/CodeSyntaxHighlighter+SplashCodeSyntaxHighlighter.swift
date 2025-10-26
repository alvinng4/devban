import MarkdownUI
import Splash
import SwiftUI

/// Splash code syntax highlighter to be used with MarkdownUI and Splash.
///
/// Originally from MarkdownUI library demo to render code blocks with syntax highlighting
/// (https://github.com/gonzalezreal/swift-markdown-ui/)
///
/// - Parameters: theme: Splash Theme
struct SplashCodeSyntaxHighlighter: CodeSyntaxHighlighter
{
    private let syntaxHighlighter: SyntaxHighlighter<TextOutputFormat>

    init(theme: Splash.Theme)
    {
        syntaxHighlighter = SyntaxHighlighter(format: TextOutputFormat(theme: theme))
    }

    func highlightCode(_ content: String, language: String?) -> Text
    {
        guard language != nil
        else
        {
            return Text(content)
        }

        return syntaxHighlighter.highlight(content)
    }
}

extension CodeSyntaxHighlighter where Self == SplashCodeSyntaxHighlighter
{
    static func splash(theme: Splash.Theme) -> Self
    {
        SplashCodeSyntaxHighlighter(theme: theme)
    }
}
