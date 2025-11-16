import FirebaseFirestore
import FirebaseSharedSwift
import Foundation

struct DevbanTeam: Codable
{
    enum Role: Codable
    {
        case admin
        case normal
    }

    var id: String
    var teamName: String
    var createdDate: Date?
    var members: [String: Role]
    var licenseID: String
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

    static func createNewTeamProfile(team: DevbanTeam) async throws
    {
        let teamDoc = DevbanTeam.getTeamDocument(team.id)
        let document = try await teamDoc.getDocument()

        if (!document.exists)
        {
            try teamDoc.setData(
                from: team,
                merge: false,
            )
        }
    }
}
