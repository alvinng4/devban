import SwiftUI

/// A Neobrutalist segmented control–style container that switches between string-labeled tabs and renders the content
/// for the current selection.
///
/// - Parameters:
///     - options: The list of tab identifiers shown as segment labels.
///     - defaultSelection: The initially selected tab. Must be contained in `options`.
///     - content: A closure that produces the view for a given option.
///
/// ## Usage
/// ```swift
///    NeobrutalismRoundedRectangleTabView(
///        options: ["morning", "night"],
///        defaultSelection: "morning",
///    )
///    { option in
///        switch (option)
///        {
///            case "morning":
///                return Text("Good morning!")
///                    .frame(maxWidth: .infinity, maxHeight: .infinity)
///            case "night":
///                return Text("Good night!")
///                    .frame(maxWidth: .infinity, maxHeight: .infinity)
///            case _:
///                return Text("Error!")
///                    .frame(maxWidth: .infinity, maxHeight: .infinity)
///        }
///    }
///    .padding()
/// ```
struct NeobrutalismRoundedRectangleTabView<Content: View>: View
{
    init(
        options: [String],
        defaultSelection: String,
        content: @escaping (String) -> Content,
    )
    {
        self.options = options
        self.content = content

        guard (options.contains(defaultSelection))
        else
        {
            fatalError("defaultSelection: \"\(defaultSelection)\" is not in options: \(options)")
        }

        _selection = State(initialValue: defaultSelection)
    }

    @Environment(\.colorScheme) private var colorScheme

    @State private var selection: String
    private let options: [String]
    private let content: (String) -> Content

    private let fontSize: Double = 15
    private let selectedTextColor: Color = .white
    private let slowEaseOut = Animation.timingCurve(0.2, 0, 0.2, 1, duration: 0.25)

    @Namespace private var animation

    private var unselectedBackgroundColor: Color
    {
        colorScheme == .dark ? .darkBackground : .white
    }

    private var unselectedTextColor: Color
    {
        colorScheme == .dark ? .white : .black
    }

    var body: some View
    {
        VStack(spacing: 0)
        {
            // MARK: Tabs

            HStack(spacing: 0)
            {
                ForEach(options.indices, id: \.self)
                { index in
                    HStack(spacing: 0)
                    {
                        Button
                        {
                            withAnimation(slowEaseOut)
                            {
                                selection = options[index]
                            }
                        }
                        label:
                        {
                            Text(options[index])
                                .lineLimit(1)
                                .font(.system(size: fontSize, weight: .bold))
                                .padding(.vertical, 12)
                                .foregroundColor(
                                    selection == options[index] ? selectedTextColor : unselectedTextColor,
                                )
                                .frame(maxWidth: .infinity)
                        }
                        .background(
                            selection == options[index] ? ThemeManager.shared.buttonColor : unselectedBackgroundColor,
                        )
                        .buttonStyle(PlainButtonStyle())

                        // MARK: Dividing vertical line

                        .overlay(alignment: .trailing)
                        {
                            if (index < options.count - 1)
                            {
                                Rectangle()
                                    .frame(width: 2)
                                    .foregroundStyle(.black)
                            }
                        }
                    }
                }
            }

            // MARK: Dividing horizontal line

            Rectangle()
                .frame(height: 2)
                .foregroundStyle(.black)

            // MARK: The tab content

            content(selection)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .shadowedBorderRoundedRectangle()
    }
}
