import SwiftUI

/// A button style that removes the default visual effects when pressed (e.g. highlighting).
struct PlainButtonStyle: ButtonStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        // Only apply content shape to make it clickable everywhere within the button
        return configuration.label
            .contentShape(Rectangle())
    }
}
