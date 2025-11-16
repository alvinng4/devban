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

    var uid: String
    var teamName: String
    var createdDate: Date?
    var members: [String: Role]
    var licenseID: String
}

extension DevbanTeam
{
    static func updateDatabaseData(uid: String, data: [String: Any]) async throws
    {
        try await DevbanTeam.getTeamDocument(uid).updateData(data)
    }

    static func checkIfLisenceValid(licenseID: String) async throws -> Bool
    {
        let licenseDoc = Firestore.firestore().collection("licenses").document(licenseID)
        let document = try await licenseDoc.getDocument()

        return document.exists
    }
}

extension DevbanTeam
{
    static func getTeam(_ uid: String) async throws -> DevbanTeam
    {
        return try await DevbanTeam.getTeamDocument(uid).getDocument(
            as: DevbanTeam.self,
            decoder: decoder,
        )
    }

    static func getTeamCollection() -> CollectionReference
    {
        return Firestore.firestore().collection("teams")
    }

    static func getTeamDocument(_ uid: String) -> DocumentReference
    {
        return DevbanTeam.getTeamCollection().document(uid)
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
        let teamDoc = DevbanTeam.getTeamDocument(team.uid)
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
