import FirebaseAuth
import SwiftUI

@Observable
final class DevbanUserContainer
{
    @MainActor
    static let shared: DevbanUserContainer = .init()

    @MainActor
    private init() {}

    var loggedIn: Bool = false
    var isUserProfileCreated: Bool = false
    private var user: DevbanUser?

    // Data from auth
    var authUid: String?
    var authEmail: String?
    var authDisplayName: String?

    func loginUser(with user: User) async throws
    {
        authUid = user.uid
        authEmail = user.email
        authDisplayName = user.displayName

        self.user = try await DevbanUser.getUser(user.uid)
        loggedIn = true
    }

    func logoutUser()
    {
        loggedIn = false
        isUserProfileCreated = false
        user = nil
        authUid = nil
        authEmail = nil
        authDisplayName = nil
    }

    func getUid() -> String?
    {
        return user?.uid ?? nil
    }

    func getTheme() -> ThemeManager.DefaultTheme
    {
        return user?.getTheme() ?? .blue
    }

    func getPreferredColorScheme() -> ThemeManager.PreferredColorScheme
    {
        return user?.getPreferredColorScheme() ?? .auto
    }

    func setTheme(_ theme: ThemeManager.DefaultTheme)
    {
        guard let user else { return }
        user.setTheme(theme)
        Task
        {
            self.user = try await DevbanUser.getUser(user.uid)
        }
    }

    func setPreferredColorScheme(_ preferredColorScheme: ThemeManager.PreferredColorScheme)
    {
        guard let user else { return }
        user.setPreferredColorScheme(preferredColorScheme)
        Task
        {
            self.user = try await DevbanUser.getUser(user.uid)
        }
    }
}
