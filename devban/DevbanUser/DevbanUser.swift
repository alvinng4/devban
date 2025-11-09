import SwiftUI

@Observable
final class DevbanUser
{
    enum PreferredColorScheme: String
    {
        case auto = "Auto"
        case light = "Light"
        case dark = "Dark"
    }

    @MainActor
    static let shared: DevbanUser = .init()

    @MainActor
    private init()
    {
        preferredColorScheme = .auto
        theme = .blue

        // ColorScheme to be updated when MainView is initialized
        themeManager = ThemeManager(
            theme: .blue,
            colorScheme: .light,
        )
    }

    var loggedIn: Bool = false
    var uid: String?
    var email: String?
    var photoUrl: String?
    var preferredColorScheme: PreferredColorScheme
    var theme: DefaultTheme
    private var themeManager: ThemeManager

    func loginUser(with userData: AuthDataResultModel)
    {
        uid = userData.uid
        email = userData.email
        photoUrl = userData.photoURL

        loggedIn = true
    }

    func logoutUser()
    {
        loggedIn = false
        uid = nil
        email = nil
        photoUrl = nil
    }

    func getActualColorScheme(_ colorScheme: ColorScheme) -> ColorScheme
    {
        switch (preferredColorScheme)
        {
            case .auto:
                return colorScheme
            case .light:
                return .light
            case .dark:
                return .dark
        }
    }

    var backgroundColor: Color
    {
        return themeManager.backgroundColor
    }

    var buttonColor: Color
    {
        return themeManager.buttonColor
    }

    func updateTheme(colorScheme: ColorScheme)
    {
        themeManager.updateTheme(theme: theme, colorScheme: getActualColorScheme(colorScheme))
    }

    func updateTheme(theme: DefaultTheme, colorScheme: ColorScheme)
    {
        themeManager.updateTheme(theme: theme, colorScheme: getActualColorScheme(colorScheme))
    }
}
