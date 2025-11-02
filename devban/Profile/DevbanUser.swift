import Foundation

@Observable
final class DevbanUser
{
    @MainActor
    static let shared: DevbanUser = .init()

    @MainActor
    private init() {}

    var loggedIn: Bool = false
    var uid: String?
    var email: String?
    var photoUrl: String?

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
