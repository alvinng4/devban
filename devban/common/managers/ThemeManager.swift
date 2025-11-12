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
    enum DefaultTheme: String
    {
        case blue = "Blue"
        case green = "Green"
        case orange = "Orange"
    }

    enum PreferredColorScheme: String
    {
        case auto = "Auto"
        case light = "Light"
        case dark = "Dark"
    }

    @MainActor
    static let shared: ThemeManager = ThemeManager()

    @MainActor
    private init()
    {
        // At this point, we do not know the theme and colorScheme yet.
        // Default to blue and light, update later
        let theme: DefaultTheme = .blue
        let colorScheme: ColorScheme = .light

        backgroundColor = ThemeManager.getBackgroundColor(theme: theme, colorScheme: colorScheme)
        buttonColor = ThemeManager.getButtonColor(theme: theme)
    }

    var backgroundColor: Color
    var buttonColor: Color

    @MainActor
    func updateTheme(theme: DefaultTheme, colorScheme: ColorScheme, preferredColorScheme: PreferredColorScheme)
    {
        let actualColorScheme: ColorScheme = getActualColorScheme(
            preferredColorScheme: preferredColorScheme,
            colorScheme: colorScheme,
        ) ?? colorScheme
        backgroundColor = ThemeManager.getBackgroundColor(theme: theme, colorScheme: actualColorScheme)
        buttonColor = ThemeManager.getButtonColor(theme: theme)
    }

    func getActualColorScheme(preferredColorScheme: PreferredColorScheme, colorScheme _: ColorScheme) -> ColorScheme?
    {
        switch (preferredColorScheme)
        {
            case .auto:
                return nil
            case .light:
                return .light
            case .dark:
                return .dark
        }
    }

    @MainActor
    private static func getBackgroundColor(theme: DefaultTheme, colorScheme: ColorScheme) -> Color
    {
        return (
            colorScheme == .dark,
        ) ? ThemeManager.getBackgroundColorDark(theme: theme) : ThemeManager.getBackgroundColorLight(theme: theme)
    }

    @MainActor
    private static func getBackgroundColorLight(theme: DefaultTheme) -> Color
    {
        switch (theme)
        {
            case .blue:
                return Constants.defaultBackgroundBlue
            case .green:
                return Constants.defaultBackgroundGreen
            case .orange:
                return Constants.defaultBackgroundOrange
        }
    }

    @MainActor
    private static func getBackgroundColorDark(theme: DefaultTheme) -> Color
    {
        switch (theme)
        {
            case .blue:
                return Constants.defaultBackgroundBlueDark
            case .green:
                return Constants.defaultBackgroundGreenDark
            case .orange:
                return Constants.defaultBackgroundOrangeDark
        }
    }

    @MainActor
    private static func getButtonColor(theme: DefaultTheme) -> Color
    {
        switch (theme)
        {
            case .blue:
                return Constants.defaultButtonBlue
            case .green:
                return Constants.defaultButtonGreen
            case .orange:
                return Constants.defaultButtonOrange
        }
    }

    /// Default hard-coded color values for some default themes.
    private enum Constants
    {
        // MARK: Blue

        static let defaultBackgroundBlueR: CGFloat = 0.796
        static let defaultBackgroundBlueG: CGFloat = 0.941
        static let defaultBackgroundBlueB: CGFloat = 1.0
        static let defaultBackgroundBlueOpacity: CGFloat = 1.0
        static let defaultBackgroundBlue: Color = .init(
            red: defaultBackgroundBlueR,
            green: defaultBackgroundBlueG,
            blue: defaultBackgroundBlueB,
            opacity: defaultBackgroundBlueOpacity,
        )

        static let defaultBackgroundBlueDarkR: CGFloat = 0.124
        static let defaultBackgroundBlueDarkG: CGFloat = 0.160
        static let defaultBackgroundBlueDarkB: CGFloat = 0.294
        static let defaultBackgroundBlueDarkOpacity: CGFloat = 1.0
        static let defaultBackgroundBlueDark: Color = .init(
            red: defaultBackgroundBlueDarkR,
            green: defaultBackgroundBlueDarkG,
            blue: defaultBackgroundBlueDarkB,
            opacity: defaultBackgroundBlueDarkOpacity,
        )

        static let defaultButtonBlueR: CGFloat = 0.00137
        static let defaultButtonBlueG: CGFloat = 0.631
        static let defaultButtonBlueB: CGFloat = 0.847
        static let defaultButtonBlueOpacity: CGFloat = 1.0
        static let defaultButtonBlue: Color = .init(
            red: defaultButtonBlueR,
            green: defaultButtonBlueG,
            blue: defaultButtonBlueB,
            opacity: defaultButtonBlueOpacity,
        )

        // MARK: Green

        static let defaultBackgroundGreenR: CGFloat = 0.886
        static let defaultBackgroundGreenG: CGFloat = 0.933
        static let defaultBackgroundGreenB: CGFloat = 0.839
        static let defaultBackgroundGreenOpacity: CGFloat = 1.0
        static let defaultBackgroundGreen: Color = .init(
            red: defaultBackgroundGreenR,
            green: defaultBackgroundGreenG,
            blue: defaultBackgroundGreenB,
            opacity: defaultBackgroundGreenOpacity,
        )

        static let defaultBackgroundGreenDarkR: CGFloat = 0.169
        static let defaultBackgroundGreenDarkG: CGFloat = 0.239
        static let defaultBackgroundGreenDarkB: CGFloat = 0.0863
        static let defaultBackgroundGreenDarkOpacity: CGFloat = 1.0
        static let defaultBackgroundGreenDark: Color = .init(
            red: defaultBackgroundGreenDarkR,
            green: defaultBackgroundGreenDarkG,
            blue: defaultBackgroundGreenDarkB,
            opacity: defaultBackgroundGreenDarkOpacity,
        )

        static let defaultButtonGreenR: CGFloat = 0.525
        static let defaultButtonGreenG: CGFloat = 0.725
        static let defaultButtonGreenB: CGFloat = 0.325
        static let defaultButtonGreenOpacity: CGFloat = 1.0
        static let defaultButtonGreen: Color = .init(
            red: defaultButtonGreenR,
            green: defaultButtonGreenG,
            blue: defaultButtonGreenB,
            opacity: defaultButtonGreenOpacity,
        )

        // MARK: Orange

        static let defaultBackgroundOrangeR: CGFloat = 0.988
        static let defaultBackgroundOrangeG: CGFloat = 0.929
        static let defaultBackgroundOrangeB: CGFloat = 0.843
        static let defaultBackgroundOrangeOpacity: CGFloat = 1.0
        static let defaultBackgroundOrange: Color = .init(
            red: defaultBackgroundOrangeR,
            green: defaultBackgroundOrangeG,
            blue: defaultBackgroundOrangeB,
            opacity: defaultBackgroundOrangeOpacity,
        )

        static let defaultBackgroundOrangeDarkR: CGFloat = 0.325
        static let defaultBackgroundOrangeDarkG: CGFloat = 0.208
        static let defaultBackgroundOrangeDarkB: CGFloat = 0.0510
        static let defaultBackgroundOrangeDarkOpacity: CGFloat = 1.0
        static let defaultBackgroundOrangeDark: Color = .init(
            red: defaultBackgroundOrangeDarkR,
            green: defaultBackgroundOrangeDarkG,
            blue: defaultBackgroundOrangeDarkB,
            opacity: defaultBackgroundOrangeDarkOpacity,
        )

        static let defaultButtonOrangeR: CGFloat = 0.953
        static let defaultButtonOrangeG: CGFloat = 0.686
        static let defaultButtonOrangeB: CGFloat = 0.239
        static let defaultButtonOrangeOpacity: CGFloat = 1.0
        static let defaultButtonOrange: Color = .init(
            red: defaultButtonOrangeR,
            green: defaultButtonOrangeG,
            blue: defaultButtonOrangeB,
            opacity: defaultButtonOrangeOpacity,
        )
    }
}
