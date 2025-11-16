import FirebaseFirestore
import FirebaseSharedSwift
import Foundation

struct License: Codable
{
    var id: String
    var teamID: String?
}

extension License
{
    static func getLicense(_ id: String) async throws -> License
    {
        return try await License.getLicenseDocument(id).getDocument(
            as: License.self,
            decoder: decoder,
        )
    }

    static func getLicenseCollection() -> CollectionReference
    {
        return Firestore.firestore().collection("licenses")
    }

    static func getLicenseDocument(_ id: String) -> DocumentReference
    {
        return License.getLicenseCollection().document(id)
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
