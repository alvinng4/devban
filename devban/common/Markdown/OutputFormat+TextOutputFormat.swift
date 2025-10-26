import MarkdownUI
import Splash
import SwiftUI

/// Text output format to be used with MarkdownUI and Splash.
///
/// Originally from MarkdownUI library demo to render code blocks with syntax highlighting
/// (https://github.com/gonzalezreal/swift-markdown-ui/)
///
/// - Parameters: theme: Splash Theme
struct TextOutputFormat: OutputFormat
{
    private let theme: Splash.Theme

    init(theme: Splash.Theme)
    {
        self.theme = theme
    }

    func makeBuilder() -> Builder
    {
        Builder(theme: theme)
    }
}

extension TextOutputFormat
{
    struct Builder: OutputBuilder
    {
        private let theme: Splash.Theme
        private var accumulatedText: [Text]

        fileprivate init(theme: Splash.Theme)
        {
            self.theme = theme
            accumulatedText = []
        }

        mutating func addToken(_ token: String, ofType type: TokenType)
        {
            let color = theme.tokenColors[type] ?? theme.plainTextColor
            accumulatedText.append(Text(token).foregroundColor(.init(color)))
        }

        mutating func addPlainText(_ text: String)
        {
            accumulatedText.append(
                Text(text).foregroundColor(.init(theme.plainTextColor)),
            )
        }

        mutating func addWhitespace(_ whitespace: String)
        {
            accumulatedText.append(Text(whitespace))
        }

        func build() -> Text
        {
            accumulatedText.reduce(Text(""))
            {
                return Text("\($0)\($1)")
            }
        }
    }
}
