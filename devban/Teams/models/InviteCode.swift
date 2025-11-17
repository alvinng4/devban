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
}

extension DevbanTeamInviteCode
{
    static func getInviteCodeCollection() -> CollectionReference
    {
        return Firestore.firestore().collection("team_invite_codes")
    }

    static func getnviteCodeDocument(_ id: String) -> DocumentReference
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
