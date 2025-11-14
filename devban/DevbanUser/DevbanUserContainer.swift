import FirebaseAuth
import SwiftUI

@Observable
final class DevbanUserContainer
{
    @MainActor
    static let shared: DevbanUserContainer = .init()

    @MainActor
    private init()
    {
        user = nil
    }

    var user: DevbanUser?

    var isLoggedIn: Bool
    {
        return !(user == nil)
    }

    func loginUser(with user: User)
    {
        let tempUser: DevbanUser = .init(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName,
            preferredColorScheme: .auto,
            theme: .blue,
        )
        self.user = tempUser
    }

    func logoutUser()
    {
        self.user = nil
    }
}
