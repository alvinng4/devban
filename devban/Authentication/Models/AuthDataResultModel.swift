import FirebaseAuth
import Foundation

/// A model struct representing authentication result data from Firebase.
///
/// This struct encapsulates user details like UID, email, and photo URL for easy handling in authentication flows.
/// It is initialized from a Firebase `User` object.
///
/// ## Overview
/// `AuthDataResultModel` provides:
/// - Unique user identifier (UID)
/// - Optional email address
/// - Optional photo URL as a string
struct AuthDataResultModel
{
    /// The unique identifier for the authenticated user.
    let uid: String
    /// The user's email address, if available.
    let email: String?
    /// The URL string for the user's profile photo, if available.
    let photoURL: String?
    /// Initializes the model from a Firebase `User` object.
    ///
    /// - Parameter user: The Firebase `User` instance to extract data from.
    init(user: User)
    {
        self.uid = user.uid
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
    }
}
