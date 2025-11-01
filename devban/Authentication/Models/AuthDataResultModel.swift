import FirebaseAuth
import Foundation

struct AuthDataResultModel
{
    let uid: String
    let email: String?
    let photoURL: String?

    init(user: User)
    {
        self.uid = user.uid
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
    }
}
