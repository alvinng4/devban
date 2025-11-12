import SwiftUI

@Observable
final class DevbanUser
{
    @MainActor
    static let shared: DevbanUser = .init()

    @MainActor
    private init()
    {
        preferredColorScheme = .auto
        theme = .blue
    }

    var loggedIn: Bool = false
    var uid: String?
    var email: String?
    var photoUrl: String?
    var preferredColorScheme: ThemeManager.PreferredColorScheme
    var theme: ThemeManager.DefaultTheme

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
}
