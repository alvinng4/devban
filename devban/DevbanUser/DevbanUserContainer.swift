import FirebaseAuth
import SwiftUI

/// A singleton container managing the current user's authentication state and profile data.
///
/// This class serves as the central access point for user and team information throughout
/// the application. It maintains the login state, user profile, team membership, and provides
/// convenient accessors for user settings.
@Observable
final class DevbanUserContainer
{
    /// Shared singleton instance accessible from the main actor
    @MainActor
    static let shared: DevbanUserContainer = .init()

    @MainActor
    private init() {}

    /// Whether the user is currently logged in
    var loggedIn: Bool = false
    /// Whether the user profile has been created in the database
    var isUserProfileCreated: Bool = false
    /// The current user's profile data
    private var user: DevbanUser?
    /// The current user's team data
    private var team: DevbanTeam?

    /// Authentication data from Firebase Auth
    var authUid: String?
    var authEmail: String?
    var authDisplayName: String?

    /// Whether the user is a member of a team
    var hasTeam: Bool
    {
        return team != nil
    }

    /// Logs in a user by loading their profile and team data from Firestore.
    ///
    /// - Parameter user: The Firebase Auth user object
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
                try await setTeam(id: teamID)
            }
            catch
            {
                print(error.localizedDescription)
            }
        }

        loggedIn = true
    }

    /// Logs out the current user and clears all cached data.
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

    /// Sets the user's current team by loading it from Firestore.
    ///
    /// - Parameter id: The team's unique identifier
    func setTeam(id: String) async throws
    {
        self.team = try await DevbanTeam.getTeam(id)
    }

    /// Returns the name of the user's current team.
    func getTeamName() -> String?
    {
        return self.team?.teamName
    }

    /// Returns the user's role in their current team.
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

    /// Returns the current user's unique identifier.
    func getUid() -> String?
    {
        return user?.uid
    }

    /// Returns the current user's display name.
    func getDisplayName() -> String?
    {
        return authDisplayName
    }

    /// Returns the current team's unique identifier.
    func getTeamId() -> String?
    {
        return team?.id
    }

    /// Returns the number of members in the current team.
    func getTeamMembersCount() -> Int?
    {
        return team?.members.count
    }

    /// Returns the user's selected theme preference.
    func getTheme() -> ThemeManager.DefaultTheme
    {
        return user?.getTheme() ?? .blue
    }

    /// Returns the user's color scheme preference.
    func getPreferredColorScheme() -> ThemeManager.PreferredColorScheme
    {
        return user?.getPreferredColorScheme() ?? .auto
    }

    /// Returns whether sound effects are enabled.
    func getSoundEffectSetting() -> Bool
    {
        return user?.getSoundEffectSetting() ?? true
    }

    /// Returns whether haptic feedback is enabled.
    func getHapticEffectSetting() -> Bool
    {
        return user?.getHapticEffectSetting() ?? true
    }

    /// Returns the user's current experience points.
    func getExp() -> Int
    {
        return user?.getExp() ?? 0
    }

    /// Updates the user's theme and refreshes their profile from Firestore.
    ///
    /// - Parameter theme: The theme to apply
    func setTheme(_ theme: ThemeManager.DefaultTheme)
    {
        guard let user else { return }
        user.setTheme(theme)
        Task
        {
            self.user = try await DevbanUser.getUser(user.uid)
        }
    }

    /// Updates the user's color scheme preference and refreshes their profile.
    ///
    /// - Parameter preferredColorScheme: The color scheme preference to apply
    func setPreferredColorScheme(_ preferredColorScheme: ThemeManager.PreferredColorScheme)
    {
        guard let user else { return }
        user.setPreferredColorScheme(preferredColorScheme)
        Task
        {
            self.user = try await DevbanUser.getUser(user.uid)
        }
    }

    /// Updates the user's sound effect setting and refreshes their profile.
    ///
    /// - Parameter option: Whether sound effects should be enabled
    func setSoundEffectSetting(_ option: Bool)
    {
        guard let user else { return }
        user.setSoundEffectSetting(option)
        Task
        {
            self.user = try await DevbanUser.getUser(user.uid)
        }
    }

    /// Updates the user's haptic feedback setting and refreshes their profile.
    ///
    /// - Parameter option: Whether haptic feedback should be enabled
    func setHapticEffectSetting(_ option: Bool)
    {
        guard let user else { return }
        user.setHapticEffectSetting(option)
        Task
        {
            self.user = try await DevbanUser.getUser(user.uid)
        }
    }

    /// Adds experience points to the user and refreshes their profile.
    ///
    /// - Parameter exp: The amount of experience to add
    func addExp(_ exp: Int)
    {
        guard let user else { return }
        user.addExp(exp)
        Task
        {
            self.user = try await DevbanUser.getUser(user.uid)
        }
    }

    /// Removes the user from their current team in both user and team documents.
    func quitTeam() async throws
    {
        guard let userID = user?.uid,
              let teamID = team?.id
        else
        {
            throw NSError(
                domain: "Auth",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Failed to get userID or teamID",
                ],
            )
        }

        try await DevbanUser.removeTeamFromUser(uid: userID)
        try await DevbanTeam.deleteUser(teamId: teamID, uid: userID)

        self.team = nil
        self.user?.teamId = nil
    }
}
