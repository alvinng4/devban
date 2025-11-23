import FirebaseFirestore
import FirebaseSharedSwift
import SwiftUI

/// Represents a user in the Devban application with their profile and settings.
///
/// This struct stores user information including authentication details, team membership,
/// preferences (theme, sound, haptics), and gamification data (experience points).
struct DevbanUser: Codable
{
    /// The unique identifier from Firebase Authentication
    var uid: String
    /// The user's display name
    var displayName: String
    /// Timestamp of the user's last access to the application
    var lastAccess: Date?
    /// Timestamp when the user account was created
    var createdDate: Date?
    /// The ID of the team the user belongs to
    var teamId: String?
    /// User's preferred color scheme (auto, light, or dark)
    private var preferredColorScheme: ThemeManager.PreferredColorScheme?
    /// User's selected theme (blue, green, or orange)
    private var theme: ThemeManager.DefaultTheme?
    /// Whether sound effects are enabled
    private var soundEffectOn: Bool?
    /// Whether haptic feedback is enabled
    private var hapticEffectOn: Bool?
    /// User's experience points for gamification
    private var exp: Int?
}

extension DevbanUser
{
    /// Updates the user document in Firestore with the provided data.
    ///
    /// - Parameters:
    ///   - uid: The user's unique identifier
    ///   - data: Dictionary of fields to update
    static func updateDatabaseData(uid: String, data: [String: Any]) async throws
    {
        try await DevbanUser.getUserDocument(uid).updateData(data)
    }

    /// Removes the team association from a user's profile.
    ///
    /// - Parameter uid: The user's unique identifier
    static func removeTeamFromUser(uid: String) async throws
    {
        try await DevbanUser.getUserDocument(uid).updateData(
            ["team_id": FieldValue.delete()],
        )
    }

    /// Deletes a user's document from Firestore.
    ///
    /// - Parameter uid: The user's unique identifier
    static func deleteUser(uid: String) async throws
    {
        try await DevbanUser.getUserDocument(uid).delete()
    }

    /// Returns the user's selected theme, defaulting to blue if not set.
    func getTheme() -> ThemeManager.DefaultTheme
    {
        return theme ?? .blue
    }

    /// Updates the user's theme preference in Firestore.
    ///
    /// - Parameter theme: The theme to apply
    func setTheme(_ theme: ThemeManager.DefaultTheme)
    {
        let data: [String: Any] = [
            "theme": theme.rawValue,
        ]
        let uid: String = self.uid

        Task
        {
            do
            {
                try await DevbanUser.updateDatabaseData(uid: uid, data: data)
            }
            catch
            {
                print("DevbanUser.setTheme: \(error.localizedDescription)")
            }
        }
    }

    /// Returns the user's preferred color scheme, defaulting to auto if not set.
    func getPreferredColorScheme() -> ThemeManager.PreferredColorScheme
    {
        return preferredColorScheme ?? .auto
    }

    /// Updates the user's preferred color scheme in Firestore.
    ///
    /// - Parameter preferredColorScheme: The color scheme preference to apply
    func setPreferredColorScheme(_ preferredColorScheme: ThemeManager.PreferredColorScheme)
    {
        let data: [String: Any] = [
            "preferred_color_scheme": preferredColorScheme.rawValue,
        ]
        let uid: String = self.uid

        Task
        {
            do
            {
                try await DevbanUser.updateDatabaseData(uid: uid, data: data)
            }
            catch
            {
                print("DevbanUser.setPreferredColorScheme: \(error.localizedDescription)")
            }
        }
    }

    /// Returns whether sound effects are enabled, defaulting to true.
    func getSoundEffectSetting() -> Bool
    {
        return soundEffectOn ?? true
    }

    /// Updates the user's sound effect preference in Firestore.
    ///
    /// - Parameter option: Whether sound effects should be enabled
    func setSoundEffectSetting(_ option: Bool)
    {
        let data: [String: Any] = [
            "sound_effect_on": option,
        ]
        let uid: String = self.uid

        Task
        {
            do
            {
                try await DevbanUser.updateDatabaseData(uid: uid, data: data)
            }
            catch
            {
                print("DevbanUser.setSoundEffectSetting: \(error.localizedDescription)")
            }
        }
    }

    /// Returns whether haptic feedback is enabled, defaulting to true.
    func getHapticEffectSetting() -> Bool
    {
        return hapticEffectOn ?? true
    }

    /// Updates the user's haptic feedback preference in Firestore.
    ///
    /// - Parameter option: Whether haptic feedback should be enabled
    func setHapticEffectSetting(_ option: Bool)
    {
        let data: [String: Any] = [
            "haptic_effect_on": option,
        ]
        let uid: String = self.uid

        Task
        {
            do
            {
                try await DevbanUser.updateDatabaseData(uid: uid, data: data)
            }
            catch
            {
                print("DevbanUser.setHapticEffectSetting: \(error.localizedDescription)")
            }
        }
    }

    /// Returns the user's experience points, defaulting to 0.
    func getExp() -> Int
    {
        return exp ?? 0
    }

    /// Adds experience points to the user's total and updates Firestore.
    ///
    /// - Parameter expChange: The amount of experience to add (can be negative)
    func addExp(_ expChange: Int)
    {
        let data: [String: Any] = [
            "exp": getExp() + expChange,
        ]
        let uid: String = self.uid

        Task
        {
            do
            {
                try await DevbanUser.updateDatabaseData(uid: uid, data: data)
            }
            catch
            {
                print("DevbanUser.setExp: \(error.localizedDescription)")
            }
        }
    }
}

extension DevbanUser
{
    /// Retrieves a user's complete profile from Firestore.
    ///
    /// - Parameter uid: The user's unique identifier
    /// - Returns: The user's DevbanUser object
    static func getUser(_ uid: String) async throws -> DevbanUser
    {
        return try await DevbanUser.getUserDocument(uid).getDocument(
            as: DevbanUser.self,
            decoder: decoder,
        )
    }

    /// Retrieves a user's display name from Firestore.
    ///
    /// - Parameter uid: The user's unique identifier
    /// - Returns: The user's display name
    static func getDisplayName(_ uid: String) async throws -> String
    {
        try await getUser(uid).displayName
    }

    /// Returns the Firestore collection reference for users.
    static func getUserCollection() -> CollectionReference
    {
        return Firestore.firestore().collection("users")
    }

    /// Returns the Firestore document reference for a specific user.
    ///
    /// - Parameter uid: The user's unique identifier
    static func getUserDocument(_ uid: String) -> DocumentReference
    {
        return DevbanUser.getUserCollection().document(uid)
    }

    /// Firestore encoder configured to convert camelCase to snake_case.
    private static var encoder: Firestore.Encoder
    {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }

    /// Firestore decoder configured to convert snake_case to camelCase.
    private static var decoder: Firestore.Decoder
    {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    /// Creates a new user profile in Firestore if it doesn't already exist.
    ///
    /// - Parameters:
    ///   - uid: The user's unique identifier
    ///   - displayName: The user's display name
    static func createNewUserProfile(uid: String, displayName: String) async throws
    {
        let userDoc = DevbanUser.getUserDocument(uid)
        let document = try await userDoc.getDocument()

        if (!document.exists)
        {
            try userDoc.setData(
                from: ["uid": uid, "display_name": displayName],
                merge: true,
            )
            try await userDoc.updateData(
                ["created_date": Timestamp()],
            )
        }
    }

    /// Updates the user's authentication status in Firestore, creating a profile if needed.
    ///
    /// - Parameters:
    ///   - uid: The user's unique identifier
    ///   - displayName: The user's display name
    static func updateUserStatusToDatabase(uid: String, displayName: String) async throws
    {
        let userDoc = DevbanUser.getUserDocument(uid)
        let document = try await userDoc.getDocument()

        if (!document.exists)
        {
            try await DevbanUser.createNewUserProfile(
                uid: uid,
                displayName: displayName,
            )
        }

        try await DevbanUser.getUserDocument(uid).updateData(
            [
                "displayName": displayName,
                "last_access": Timestamp(),
            ],
        )
    }
}
