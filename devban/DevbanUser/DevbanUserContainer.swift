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
    private var team: DevbanTeam?

    // Data from auth
    var authUid: String?
    var authEmail: String?
    var authDisplayName: String?

    var hasTeam: Bool
    {
        return team != nil
    }

    func loginUser(with user: User) async throws
    {
        authUid = user.uid
        authEmail = user.email
        authDisplayName = user.displayName

        let devbanUser: DevbanUser = try await DevbanUser.getUser(user.uid)
        self.user = devbanUser

        if let teamID = devbanUser.teamId
        {
            do
            {
                self.team = try await DevbanTeam.getTeam(teamID)
            }
            catch
            {
                print(error.localizedDescription)
            }
        }

        loggedIn = true
    }

    func logoutUser()
    {
        loggedIn = false
        isUserProfileCreated = false
        user = nil
        team = nil
        authUid = nil
        authEmail = nil
        authDisplayName = nil
    }

    func setTeam(id: String) async throws
    {
        self.team = try await DevbanTeam.getTeam(id)
    }

    func getTeamName() -> String?
    {
        return self.team?.teamName
    }

    func getUserTeamRole() -> DevbanTeam.Role?
    {
        guard let user,
              let team
        else
        {
            return nil
        }

        return team.members[user.uid]
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
