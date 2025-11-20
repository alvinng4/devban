import Combine
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

    private static var customDecoder: Firestore.Decoder
    {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
