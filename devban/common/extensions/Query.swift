import Combine
import FirebaseFirestore
import FirebaseSharedSwift

extension Query
{
    /// Fetches documents from Firestore and decodes them to the specified type.
    ///
    /// - Parameter type: The Decodable type to decode documents to
    /// - Returns: An array of decoded objects
    func getDocuments<T: Decodable>(as _: T.Type) async throws -> [T]
    {
        let snapshot = try await self.getDocuments()

        return try snapshot.documents.map
        { document in
            return try document.data(as: T.self, decoder: Query.customDecoder)
        }
    }

    /// Adds a snapshot listener that publishes decoded documents as they change.
    ///
    /// - Parameter type: The Decodable type to decode documents to
    /// - Returns: A tuple containing a publisher for the documents and the listener registration
    func addSnapshotListener<T: Decodable>(as _: T.Type) -> (AnyPublisher<[T], Error>, ListenerRegistration)
    {
        let publisher = PassthroughSubject<[T], Error>()

        let listener = self.addSnapshotListener
        { querySnapshot, _ in
            guard let documents = querySnapshot?.documents
            else
            {
                print("No documents")
                return
            }

            let products: [T] = documents.compactMap { try? $0.data(as: T.self, decoder: Query.customDecoder) }
            publisher.send(products)
        }

        return (publisher.eraseToAnyPublisher(), listener)
    }

    /// Firestore decoder configured to convert snake_case to camelCase.
    private static var customDecoder: Firestore.Decoder
    {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
