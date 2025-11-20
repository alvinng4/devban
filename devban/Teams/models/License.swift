import FirebaseFirestore
import FirebaseSharedSwift
import Foundation

/// Represents a license that can be associated with a team.
///
/// Licenses control team creation and may have restrictions or features.
struct License: Codable
{
    /// The license's unique identifier
    var id: String
    /// The ID of the team using this license (if any)
    var teamId: String?
}

extension License
{
    /// Updates the license document in Firestore with the provided data.
    ///
    /// - Parameters:
    ///   - id: The license's unique identifier
    ///   - data: Dictionary of fields to update
    static func updateDatabaseData(id: String, data: [String: Any]) async throws
    {
        try await License.getLicenseDocument(id).updateData(data)
    }
}

extension License
{
    /// Retrieves a license from Firestore.
    ///
    /// - Parameter id: The license's unique identifier
    /// - Returns: The license object
    static func getLicense(_ id: String) async throws -> License
    {
        return try await License.getLicenseDocument(id).getDocument(
            as: License.self,
            decoder: decoder,
        )
    }

    /// Returns the Firestore collection reference for licenses.
    static func getLicenseCollection() -> CollectionReference
    {
        return Firestore.firestore().collection("licenses")
    }

    /// Returns the Firestore document reference for a specific license.
    ///
    /// - Parameter id: The license's unique identifier
    static func getLicenseDocument(_ id: String) -> DocumentReference
    {
        return License.getLicenseCollection().document(id)
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
