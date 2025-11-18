import FirebaseFirestore
import FirebaseSharedSwift
import SwiftUI

struct DevbanUser: Codable
{
    var uid: String
    var lastAccess: Date?
    var createdDate: Date?
    var teamId: String?
    private var preferredColorScheme: ThemeManager.PreferredColorScheme?
    private var theme: ThemeManager.DefaultTheme?
}

extension DevbanUser
{
    static func updateDatabaseData(uid: String, data: [String: Any]) async throws
    {
        try await DevbanUser.getUserDocument(uid).updateData(data)
    }

    static func removeTeamFromUser(uid: String) async throws
    {
        try await DevbanUser.getUserDocument(uid).updateData(
            ["team_id": FieldValue.delete()],
        )
    }

    static func deleteUser(uid: String) async throws
    {
        try await DevbanUser.getUserDocument(uid).delete()
    }

    func getTheme() -> ThemeManager.DefaultTheme
    {
        return theme ?? .blue
    }

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

    func getPreferredColorScheme() -> ThemeManager.PreferredColorScheme
    {
        return preferredColorScheme ?? .auto
    }

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
}

extension DevbanUser
{
    static func getUser(_ uid: String) async throws -> DevbanUser
    {
        return try await DevbanUser.getUserDocument(uid).getDocument(
            as: DevbanUser.self,
            decoder: decoder,
        )
    }

    static func getUserCollection() -> CollectionReference
    {
        return Firestore.firestore().collection("users")
    }

    static func getUserDocument(_ uid: String) -> DocumentReference
    {
        return DevbanUser.getUserCollection().document(uid)
    }

    private static var encoder: Firestore.Encoder
    {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }

    private static var decoder: Firestore.Decoder
    {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    static func createNewUserProfile(uid: String) async throws
    {
        let userDoc = DevbanUser.getUserDocument(uid)
        let document = try await userDoc.getDocument()

        if (!document.exists)
        {
            try userDoc.setData(
                from: ["uid": uid],
                merge: true,
            )
            try await userDoc.updateData(
                ["created_date": Timestamp()],
            )
        }
    }

    static func updateUserStatusToDatabase(uid: String) async throws
    {
        let userDoc = DevbanUser.getUserDocument(uid)
        let document = try await userDoc.getDocument()

        if (!document.exists)
        {
            try await DevbanUser.createNewUserProfile(uid: uid)
        }

        try await DevbanUser.getUserDocument(uid).updateData(
            ["last_access": Timestamp()],
        )
    }
}
