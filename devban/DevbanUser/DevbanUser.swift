import FirebaseFirestore
import FirebaseSharedSwift
import SwiftUI

struct DevbanUser: Codable
{
    var uid: String
    var preferredColorScheme: ThemeManager.PreferredColorScheme = .auto
    var theme: ThemeManager.DefaultTheme = .blue
}

extension DevbanUser
{
    private var userCollection: CollectionReference
    {
        return Firestore.firestore().collection("users")
    }

    private var userDocument: DocumentReference
    {
        return userCollection.document(self.uid)
    }

    private var encoder: Firestore.Encoder
    {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }

    private var decoder: Firestore.Decoder
    {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    func createNewUserOnDatabase() async throws
    {
        try userDocument.setData(from: self, merge: false)
    }
}
