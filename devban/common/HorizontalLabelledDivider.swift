import SwiftUI

/// Horizontal divider with a label in the middle.
///
/// - Parameters:
///     - label: The label to be placed.
///     - horizontalPadding: Padding for the label.
///     - color: Color for the label and divider.
struct HorizontalLabelledDivider: View
{
    init(label: String, horizontalPadding: CGFloat = 20, color: Color = .gray)
    {
        self.label = label
        self.horizontalPadding = horizontalPadding
        self.color = color
    }

    let label: String
    let horizontalPadding: CGFloat
    let color: Color

    var body: some View
    {
        HStack
        {
            line

            Text(label)
                .foregroundColor(color)
                .padding(horizontalPadding)

            line
        }
    }

    var line: some View
    {
        VStack
        {
            Divider().background(color)
        }
    }
}
