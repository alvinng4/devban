import FirebaseFirestore
import FirebaseSharedSwift
import Foundation

/// Represents a team in the Devban application with its members and settings.
///
/// Teams are collections of users who collaborate on tasks. Each team has a unique ID,
/// name, members with assigned roles, and associated license and invite codes.
struct DevbanTeam: Codable {
    
    /// Defines the role a user can have within a team
    enum Role: String, Codable {
        /// Team administrator with full permissions
        case admin
        /// Regular team member
        case member
    }
    
    /// The team's unique identifier
    var id: String
    
    /// The team's display name
    var teamName: String
    
    /// Timestamp when the team was created
    var createdDate: Date?
    
    /// Dictionary mapping user IDs to their roles in the team
    var members: [String: Role]
    
    /// The license ID associated with this team
    var licenseId: String
    
    /// Array of active invite codes for the team
    var inviteCodes: [String]?
}

extension DevbanTeam {
    
    /// Updates the team document in Firestore with the provided data.
    ///
    /// - Parameters:
    /// - id: The team's unique identifier
    /// - data: Dictionary of fields to update
    static func updateDatabaseData(id: String, data: [String: Any]) async throws {
        try await DevbanTeam.getTeamDocument(id).updateData(data)
    }
    
    /// Removes a user from a team's member list.
    ///
    /// - Parameters:
    /// - teamId: The team's unique identifier
    /// - uid: The user's unique identifier to remove
    static func deleteUser(teamId: String, uid: String) async throws {
        try await DevbanTeam.updateDatabaseData(
            id: teamId,
            data: [
                "members.\(uid)": FieldValue.delete(),
            ]
        )
    }
}

extension DevbanTeam {
    
    /// Retrieves a team's complete data from Firestore.
    ///
    /// - Parameter id: The team's unique identifier
    /// - Returns: The team's DevbanTeam object
    static func getTeam(_ id: String) async throws -> DevbanTeam {
        return try await DevbanTeam.getTeamDocument(id).getDocument(
            as: DevbanTeam.self,
            decoder: decoder
        )
    }
    
    /// Returns the Firestore collection reference for teams.
    static func getTeamCollection() -> CollectionReference {
        return Firestore.firestore().collection("teams")
    }
    
    /// Returns the Firestore document reference for a specific team.
    ///
    /// - Parameter id: The team's unique identifier
    static func getTeamDocument(_ id: String) -> DocumentReference {
        return DevbanTeam.getTeamCollection().document(id)
    }
    
    /// Firestore encoder configured to convert camelCase to snake_case.
    private static var encoder: Firestore.Encoder {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    
    /// Firestore decoder configured to convert snake_case to camelCase.
    private static var decoder: Firestore.Decoder {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    /// Creates a new team profile in Firestore with the creator as admin.
    ///
    /// - Parameters:
    /// - teamName: The name for the new team
    /// - creatorUid: The unique identifier of the team creator
    /// - licenseId: The license ID to associate with the team
    /// - Returns: The newly created team's unique identifier
    static func createNewTeamProfile(
        teamName: String,
        creatorUid: String,
        licenseId: String
    ) async throws -> String {
        let teamDoc = DevbanTeam.getTeamCollection().document()
        let id: String = teamDoc.documentID
        
        let docData: [String: Any] = [
            "id": id,
            "team_name": teamName,
            "created_date": Timestamp(),
            "members": [creatorUid: Role.admin.rawValue],
            "license_id": licenseId,
        ]
        
        try await teamDoc.setData(
            docData,
            merge: false
        )
        
        return id
    }
    
    /// Transfer Admin privileges
    /// - Parameters:
    /// - teamId: The team ID
    /// - fromUid: The current Admin's UID
    /// - toUid: The new Admin's UID
    static func transferAdmin(teamId: String, fromUid: String, toUid: String) async throws {
        // use transaction to ensure data consistency
        try await Firestore.firestore().runTransaction({ transaction, errorPointer in
            let teamRef = DevbanTeam.getTeamDocument(teamId)
            
            do {
                // change the new Admin's role
                transaction.updateData(
                    ["members.\(toUid)": "admin"],
                    forDocument: teamRef
                )
                
                // change the old Admin's role to member
                transaction.updateData(
                    ["members.\(fromUid)": "member"],
                    forDocument: teamRef
                )
                
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        })
    }
    
    /// Fetches the list of team members with their roles.
    /// - Parameter id: The team ID
    /// - Returns: Returns [(uid, role)] array
    static func getTeamMembersWithDetails(id: String) async throws -> [(uid: String, role: String)] {
        let team = try await DevbanTeam.getTeam(id)
        return team.members.map { (uid: $0.key, role: $0.value.rawValue) }
    }
}
