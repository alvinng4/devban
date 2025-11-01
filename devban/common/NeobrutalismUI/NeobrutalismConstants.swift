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

    /// Max width for large elements
    static let maxWidthLarge: CGFloat = 1280

    /// Max width for small elements
    static let maxWidthSmall: CGFloat = 540

    /// Horizontal padding length for main content (compact)
    static let mainContentPaddingHorizontalCompact: CGFloat = 10

    /// Horizontal padding length for main content (regular)
    static let mainContentPaddingHorizontalRegular: CGFloat = 30

    /// Vertical padding length for main content  (compact)
    static let mainContentPaddingVerticalCompact: CGFloat = 10

    /// Vertical padding length for main content  (regular)
    static let mainContentPaddingVerticalRegular: CGFloat = 30
}
