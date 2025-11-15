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
    var user: DevbanUser?

    // Data from auth
    var authUid: String?
    var authEmail: String?
    var authDisplayName: String?

    func loginUser(with user: User)
    {
        authUid = user.uid
        authEmail = user.email
        authDisplayName = user.displayName

        self.user = DevbanUser(
            uid: user.uid,
            preferredColorScheme: .auto,
            theme: .blue,
        )

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
}
