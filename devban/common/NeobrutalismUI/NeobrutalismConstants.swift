import SwiftUI

/// Contains useful constants for NeobrutalismUI, used as default parameters / internal constants.
enum NeobrutalismConstants
{
    // All Neobrutalism components have border to emphasize the content
    static let borderColor: Color = .black
    static let borderWidth: CGFloat = 2

    // All Neobrutalism components have shadows, with a slight offset from the content
    static let shadowColor: Color = .black
    static let shadowOffset: CGSize = .init(width: 4, height: 4)

    // Rounded rectangle
    static let roundedRectangleCornerRadius: CGFloat = 6

    /// For animation (e.g. Button click)
    static let animationDuration: Double = 0.15

    /// For pressable element to stay pressed when user dragged away
    static let dragTolerance: CGFloat = 150
}
