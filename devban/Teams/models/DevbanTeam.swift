import FirebaseFirestore
import FirebaseSharedSwift
import Foundation

struct DevbanTeam: Codable
{
    enum Role: String, Codable
    {
        case admin
        case member
    }

    var id: String
    var teamName: String
    var createdDate: Date?
    var members: [String: Role]
    var licenseId: String
}

extension DevbanTeam
{
    static func updateDatabaseData(id: String, data: [String: Any]) async throws
    {
        try await DevbanTeam.getTeamDocument(id).updateData(data)
    }
}

extension DevbanTeam
{
    static func getTeam(_ id: String) async throws -> DevbanTeam
    {
        return try await DevbanTeam.getTeamDocument(id).getDocument(
            as: DevbanTeam.self,
            decoder: decoder,
        )
    }

    static func getTeamCollection() -> CollectionReference
    {
        return Firestore.firestore().collection("teams")
    }

    static func getTeamDocument(_ id: String) -> DocumentReference
    {
        return DevbanTeam.getTeamCollection().document(id)
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

    static func createNewTeamProfile(
        teamName: String,
        creatorUid: String,
        licenseId: String,
    ) async throws -> String
    {
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
            merge: false,
        )

        return id
    }
}
