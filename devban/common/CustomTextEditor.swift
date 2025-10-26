import SwiftUI
import UIKit

/// Custom Text Editor Implemented with UIKit to handle modifications of text and selection programatically.
///
/// - Parameters:
///     - text: The text to be edited.
///     - selectedRange: Range of the text selection.
struct CustomTextEditor: UIViewRepresentable
{
    init(text: Binding<String>, selectedRange: Binding<NSRange>)
    {
        _text = text
        _selectedRange = selectedRange
    }

    @Binding var text: String
    @Binding var selectedRange: NSRange

    func makeCoordinator() -> Coordinator
    {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView
    {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.alwaysBounceVertical = true
        textView.font = .preferredFont(forTextStyle: .body)
        textView.backgroundColor = .clear

        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.smartInsertDeleteType = .no

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context)
    {
        let coord = context.coordinator

        // Update text only if the change did not originate in the UITextView
        if (!coord.textChangeCameFromTextView)
        {
            // Avoid resetting text when it’s already the same
            // We still need a check, but we only do it when the change
            // came from SwiftUI, not on every keystroke.
            if (uiView.text != text)
            {
                // Preserve selection as best as possible when replacing the text
                let previousSelectedRange = uiView.selectedRange
                uiView.text = text

                // Clamp the previous selection to the new text length
                let newLen = uiView.textStorage.length
                let clamped = NSIntersectionRange(
                    previousSelectedRange,
                    NSRange(location: 0, length: newLen),
                )
                uiView.selectedRange = clamped
            }
        }
        coord.textChangeCameFromTextView = false

        // Update selection only if the change did not originate in the UITextView
        if (!coord.selectionChangeCameFromTextView)
        {
            // Clamp incoming SwiftUI selection to current text length
            let clamped = NSIntersectionRange(
                selectedRange,
                NSRange(location: 0, length: uiView.textStorage.length),
            )
            if (uiView.selectedRange != clamped)
            {
                uiView.selectedRange = clamped
            }
        }
        coord.selectionChangeCameFromTextView = false
    }

    class Coordinator: NSObject, UITextViewDelegate
    {
        var parent: CustomTextEditor

        var textChangeCameFromTextView = false
        var selectionChangeCameFromTextView = false

        init(_ parent: CustomTextEditor)
        {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView)
        {
            DispatchQueue.main.async
            {
                self.textChangeCameFromTextView = true
                self.parent.text = textView.text
            }
        }

        func textViewDidChangeSelection(_ textView: UITextView)
        {
            DispatchQueue.main.async
            {
                self.selectionChangeCameFromTextView = true
                self.parent.selectedRange = textView.selectedRange
            }
        }
    }
}
