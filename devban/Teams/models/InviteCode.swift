import FirebaseFirestore
import FirebaseSharedSwift
import Foundation

struct DevbanTeamInviteCode: Codable
{
    var id: String
    var teamId: String
    var createdDate: Date
    var expiryDate: Date
    var redeemDate: Date?
    var redeemedByUid: String?
}

extension DevbanTeamInviteCode
{
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
    static func getDevbanTeamInviteCode(_ id: String) async throws -> DevbanTeamInviteCode
    {
        return try await DevbanTeamInviteCode.getInviteCodeDocument(id).getDocument(
            as: DevbanTeamInviteCode.self,
            decoder: decoder,
        )
    }

    static func updateDatabaseData(id: String, data: [String: Any]) async throws
    {
        try await DevbanTeamInviteCode.getInviteCodeDocument(id).updateData(data)
    }

    static func getInviteCodeCollection() -> CollectionReference
    {
        return Firestore.firestore().collection("team_invite_codes")
    }

    static func getInviteCodeDocument(_ id: String) -> DocumentReference
    {
        return DevbanTeamInviteCode.getInviteCodeCollection().document(id)
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
}
