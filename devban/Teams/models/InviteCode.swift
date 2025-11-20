import FirebaseFirestore
import FirebaseSharedSwift
import Foundation

/// Represents an invite code for joining a team.
///
/// Invite codes have an expiration date and can only be redeemed once. When redeemed,
/// they add the user to the team as a member.
struct DevbanTeamInviteCode: Codable
{
    /// The invite code's unique identifier
    var id: String
    /// The ID of the team this code grants access to
    var teamId: String
    /// Timestamp when the code was created
    var createdDate: Date
    /// Timestamp when the code expires
    var expiryDate: Date
    /// Timestamp when the code was redeemed (if applicable)
    var redeemDate: Date?
    /// The user ID of who redeemed this code (if applicable)
    var redeemedByUid: String?
}

extension DevbanTeamInviteCode
{
    /// Generates a new invite code for the current user's team.
    ///
    /// The code expires after 7 days and is stored in both the invite codes
    /// collection and the team's invite codes array.
    ///
    /// - Returns: The unique identifier of the generated invite code
    static func generateInviteCode() async throws -> String
    {
        let inviteCodeDoc = DevbanTeamInviteCode.getInviteCodeCollection().document()
        let id: String = inviteCodeDoc.documentID

        guard let teamId: String = DevbanUserContainer.shared.getTeamId()
        else
        {
            throw NSError(
                domain: "Auth",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Failed to get team ID.",
                ],
            )
        }

        let docData: [String: Any] = [
            "id": id,
            "team_id": teamId,
            "created_date": Timestamp(),
            "expiry_date": Timestamp(date: Date().addingTimeInterval(86400 * 7)),
        ]

        try await inviteCodeDoc.setData(
            docData,
            merge: false,
        )
        try await DevbanTeam.updateDatabaseData(
            id: teamId,
            data: ["invite_codes": FieldValue.arrayUnion([id])],
        )

        return id
    }

    /// Redeems an invite code, adding the current user to the team.
    ///
    /// This validates that the code hasn't expired or been used, then adds the user
    /// to the team and updates all relevant documents.
    ///
    /// - Parameter id: The invite code identifier to redeem
    static func redeemInviteCode(id: String) async throws
    {
        let inviteCode: DevbanTeamInviteCode = try await DevbanTeamInviteCode.getDevbanTeamInviteCode(id)

        guard let userID: String = DevbanUserContainer.shared.getUid()
        else
        {
            throw NSError(
                domain: "Auth",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Error: Failed to get userID!",
                ],
            )
        }

        let team: DevbanTeam
        do
        {
            team = try await DevbanTeam.getTeam(inviteCode.teamId)
        }
        catch
        {
            print(error.localizedDescription)
            throw NSError(
                domain: "Auth",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Error: Failed to get team information!",
                ],
            )
        }

        if (inviteCode.expiryDate < Date())
        {
            throw NSError(
                domain: "Auth",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "The invite code has been expired!",
                ],
            )
        }
        else if (inviteCode.redeemedByUid != nil)
        {
            throw NSError(
                domain: "Auth",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "The invite code has been used!",
                ],
            )
        }

        // Redeem the inviteCode
        try await DevbanTeamInviteCode.updateDatabaseData(
            id: id,
            data: [
                "redeemed_by_uid": userID,
            ],
        )

        // Add user to team
        try await DevbanTeam.updateDatabaseData(
            id: team.id,
            data: ["members.\(userID)": DevbanTeam.Role.member.rawValue],
        )

        // Add teamID to user
        try await DevbanUser.updateDatabaseData(
            uid: userID,
            data: ["team_id": team.id],
        )

        // Add team to DevbanUserContainer
        try await DevbanUserContainer.shared.setTeam(id: team.id)
    }
}

extension DevbanTeamInviteCode
{
    /// Retrieves an invite code from Firestore.
    ///
    /// - Parameter id: The invite code's unique identifier
    /// - Returns: The invite code object
    static func getDevbanTeamInviteCode(_ id: String) async throws -> DevbanTeamInviteCode
    {
        return try await DevbanTeamInviteCode.getInviteCodeDocument(id).getDocument(
            as: DevbanTeamInviteCode.self,
            decoder: decoder,
        )
    }

    /// Updates the invite code document in Firestore with the provided data.
    ///
    /// - Parameters:
    ///   - id: The invite code's unique identifier
    ///   - data: Dictionary of fields to update
    static func updateDatabaseData(id: String, data: [String: Any]) async throws
    {
        try await DevbanTeamInviteCode.getInviteCodeDocument(id).updateData(data)
    }

    /// Returns the Firestore collection reference for invite codes.
    static func getInviteCodeCollection() -> CollectionReference
    {
        return Firestore.firestore().collection("team_invite_codes")
    }

    /// Returns the Firestore document reference for a specific invite code.
    ///
    /// - Parameter id: The invite code's unique identifier
    static func getInviteCodeDocument(_ id: String) -> DocumentReference
    {
        return DevbanTeamInviteCode.getInviteCodeCollection().document(id)
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
}
