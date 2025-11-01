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
}
