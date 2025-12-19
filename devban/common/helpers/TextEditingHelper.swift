import SwiftUI

/// Helper functions for text editing (e.g. bold, copy to clipboard)
enum TextEditingHelper
{
    static func copyToClipboard(_ text: String)
    {
        UIPasteboard.general.string = text
    }

    static func toggleMarkdownInlineFormat(
        preMarker: String,
        postMarker: String,
        text: Binding<String>,
        selectedRange: Binding<NSRange>,
        placeholder: String = "text",
    )
    {
        let nsText: NSString = NSString(string: text.wrappedValue)
        let currentRange: NSRange = selectedRange.wrappedValue
        let textLength: Int = nsText.length

        guard (currentRange.location != NSNotFound),
              ((currentRange.location + currentRange.length) <= textLength)
        else
        {
            return
        }

        let preMarkerLength: Int = preMarker.count
        let postMarkerLength: Int = postMarker.count
        let selectedText = nsText.substring(with: selectedRange.wrappedValue)

        let newText: String

            // Remove marker if already exist
            = if (
                selectedText.hasPrefix(preMarker)
                    && selectedText.hasSuffix(postMarker)
                    && selectedText.count >= (preMarkerLength + postMarkerLength)
            )
        {
            String(selectedText.dropFirst(preMarkerLength).dropLast(postMarkerLength))
        }

        // Empty selection
        else if (currentRange.length == 0)
        {
            "\(preMarker)\(placeholder)\(postMarker)"
        }

        // Regular selection
        else
        {
            "\(preMarker)\(selectedText)\(postMarker)"
        }

        text.wrappedValue = nsText.replacingCharacters(in: currentRange, with: newText)
        selectedRange.wrappedValue = NSRange(
            location: currentRange.location,
            length: newText.count,
        )
    }

    static func toggleMarkdownMultilineFormat(
        preMarker: String,
        text: Binding<String>,
        selectedRange: Binding<NSRange>,
        placeholder _: String = "text",
    )
    {
        let nsText: NSString = NSString(string: text.wrappedValue)

        guard (selectedRange.wrappedValue.location != NSNotFound),
              ((selectedRange.wrappedValue.location + selectedRange.wrappedValue.length) <= nsText.length)
        else
        {
            return
        }

        let preMarkerLength: Int = preMarker.count
        var selectedText = nsText.substring(with: selectedRange.wrappedValue)

        var newText: String

        let needsNewline = (
            selectedRange.wrappedValue.location > 0
                && !nsText.substring(
                    with: NSRange(location: selectedRange.wrappedValue.location - 1, length: 1),
                ).contains("\n"),
        )

        var hasExistingMarker: Bool = false
        if (selectedRange.wrappedValue.location >= preMarkerLength)
        {
            let checkRange = NSRange(
                location: selectedRange.wrappedValue.location - preMarkerLength,
                length: preMarkerLength,
            )
            if (nsText.substring(with: checkRange) == preMarker)
            {
                hasExistingMarker = true
                selectedRange.wrappedValue = NSRange(
                    location: selectedRange.wrappedValue.location - preMarkerLength,
                    length: selectedRange.wrappedValue.length + preMarkerLength,
                )
                selectedText = nsText.substring(with: selectedRange.wrappedValue)
            }

            else if (selectedText.hasPrefix(preMarker))
            {
                hasExistingMarker = true
            }
        }

        // Remove marker if already exist
        if (hasExistingMarker)
        {
            newText = String(selectedText.dropFirst(preMarkerLength))
        }

        // Empty selection
        else if (selectedRange.wrappedValue.length == 0)
        {
            newText = needsNewline ? "\n\(preMarker)" : preMarker
        }

        // Regular selection
        else
        {
            newText = needsNewline ? "\n\(preMarker)\(selectedText)" : "\(preMarker)\(selectedText)"
        }

        text.wrappedValue = nsText.replacingCharacters(in: selectedRange.wrappedValue, with: newText)

        // Move cursor after the marker for empty selection
        if (selectedRange.wrappedValue.length == 0)
        {
            selectedRange.wrappedValue = NSRange(
                location: selectedRange.wrappedValue.location + newText.count,
                length: 0,
            )
        }

        // Keep selection for other cases
        else
        {
            selectedRange.wrappedValue = NSRange(location: selectedRange.wrappedValue.location, length: newText.count)
        }
    }

    static func addBold(text: Binding<String>, selectedRange: Binding<NSRange>)
    {
        toggleMarkdownInlineFormat(preMarker: "**", postMarker: "**", text: text, selectedRange: selectedRange)
    }

    static func addItalic(text: Binding<String>, selectedRange: Binding<NSRange>)
    {
        toggleMarkdownInlineFormat(preMarker: "_", postMarker: "_", text: text, selectedRange: selectedRange)
    }

    static func addStrikeThrough(text: Binding<String>, selectedRange: Binding<NSRange>)
    {
        toggleMarkdownInlineFormat(preMarker: "~~", postMarker: "~~", text: text, selectedRange: selectedRange)
    }

    static func addInlineCode(text: Binding<String>, selectedRange: Binding<NSRange>)
    {
        toggleMarkdownInlineFormat(preMarker: "`", postMarker: "`", text: text, selectedRange: selectedRange)
    }

    static func addUnorderedList(text: Binding<String>, selectedRange: Binding<NSRange>)
    {
        toggleMarkdownMultilineFormat(preMarker: "* ", text: text, selectedRange: selectedRange)
    }

    static func addCheckList(text: Binding<String>, selectedRange: Binding<NSRange>)
    {
        toggleMarkdownMultilineFormat(preMarker: "- [ ] ", text: text, selectedRange: selectedRange)
    }

    static func addLink(text: Binding<String>, selectedRange: Binding<NSRange>)
    {
        toggleMarkdownInlineFormat(
            preMarker: "[LinkText](",
            postMarker: ")",
            text: text,
            selectedRange: selectedRange,
            placeholder: "link",
        )
    }

    static func resetFocus()
    {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil,
        )
    }
}
