import SwiftUI

/// A centralized manager for handling custom themes throughout the application.
///
/// The `ThemeManager` provides a singleton instance that manages theme-related properties
/// such as background colors and button colors, with support for light and dark mode.
///
/// ## Usage
/// ```swift
/// // Access theme colors
/// let backgroundColor: Color = ThemeManager.shared.backgroundColor
/// let buttonColor: Color = ThemeManager.shared.buttonColor
///
/// // Update theme for color scheme changes
/// ThemeManager.shared.updateTheme(colorScheme: .dark)
/// ```
@Observable
final class ThemeManager
{
    @MainActor
    static let shared: ThemeManager = ThemeManager()

    @MainActor
    private init()
    {
        self.backgroundColor = ThemeManager.getBackgroundColor(colorScheme: .light)
        self.buttonColor = ThemeManager.getButtonColor()
    }

    var backgroundColor: Color
    var buttonColor: Color
    
    @MainActor
    func updateTheme(colorScheme: ColorScheme)
    {
        self.backgroundColor = ThemeManager.getBackgroundColor(colorScheme: colorScheme)
        self.buttonColor = ThemeManager.getButtonColor()
    }
    
    @MainActor
    static func getBackgroundColor(colorScheme: ColorScheme) -> Color
    {
        return (colorScheme == .dark) ? ThemeManager.Constants.defaultBackgroundDarkColor : ThemeManager.Constants.defaultBackgroundColor
    }
    
    @MainActor
    static func getButtonColor() -> Color
    {
        return ThemeManager.Constants.defaultButtonColor
    }
    
    /// Default hard-coded color values (orange) for basic theme. Will be updated if support custom theme
    private struct Constants
    {
        static let defaultBackgroundR: CGFloat = 0.988
        static let defaultBackgroundG: CGFloat = 0.929
        static let defaultBackgroundB: CGFloat = 0.843
        static let defaultBackgroundOpacity: CGFloat = 1.0
        static let defaultBackgroundColor: Color = Color(
            red: defaultBackgroundR,
            green: defaultBackgroundG,
            blue: defaultBackgroundB,
            opacity: defaultBackgroundOpacity
        )
        
        static let defaultBackgroundDarkR: CGFloat = 0.325
        static let defaultBackgroundDarkG: CGFloat = 0.208
        static let defaultBackgroundDarkB: CGFloat = 0.0510
        static let defaultBackgroundDarkOpacity: CGFloat = 1.0
        static let defaultBackgroundDarkColor: Color = Color(
            red: defaultBackgroundDarkR,
            green: defaultBackgroundDarkG,
            blue: defaultBackgroundDarkB,
            opacity: defaultBackgroundDarkOpacity
        )
        
        static let defaultButtonR: CGFloat = 0.953
        static let defaultButtonG: CGFloat = 0.686
        static let defaultButtonB: CGFloat = 0.239
        static let defaultButtonOpacity: CGFloat = 1.0
        static let defaultButtonColor: Color = Color(
            red: defaultButtonR,
            green: defaultButtonG,
            blue: defaultButtonB,
            opacity: defaultButtonOpacity
        )
    }
}
