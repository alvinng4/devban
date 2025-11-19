import FirebaseFirestore
import FirebaseSharedSwift

extension Query
{
    func getDocuments<T: Decodable>(as _: T.Type) async throws -> [T]
    {
        let snapshot = try await self.getDocuments()

        return try snapshot.documents.map
        { document in
            return try document.data(as: T.self, decoder: Query.customDecoder)
        }
    }

    private static var customDecoder: Firestore.Decoder
    {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
