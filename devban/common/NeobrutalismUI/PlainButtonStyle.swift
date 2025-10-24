import SwiftUI

/// A button style that removes the default visual effects when pressed (e.g. highlighting).
struct PlainButtonStyle: ButtonStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        // Simply return the label without doing anything
        configuration.label
    }
}
