import FirebaseAuth
import Foundation

/// Enum providing static helper functions for Firebase authentication tasks.
///
/// This utility handles user creation, sign-in (with email/Google), sign-out, password reset, and deletion,
/// along with status updates. It integrates with DevbanUser for login/logout state management and throws errors for
/// failures.
///
/// ## Overview
/// `AuthenticationHelper` includes:
/// - User creation with email verification
/// - Sign-in methods with verification checks
/// - Sign-out and account deletion
/// - Password reset email sending
/// - Auth status updates to shared user model
enum AuthenticationHelper
{
    /// Updates the shared user's authentication status based on the current Firebase user.
    ///
    /// Logs out if no user or email not verified; otherwise, logs in with the user's data model.
    static func updateUserAuthStatus()
    {
        guard let user = Auth.auth().currentUser,
              user.emailVerified()
        else
        {
            DevbanUserContainer.shared.logoutUser()
            return
        }

        DevbanUserContainer.shared.loginUser(with: user)
    }

    /// Creates a new user asynchronously with email and password, then sends a verification email.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Throws: Firebase authentication errors if creation or email sending fails.
    static func createUser(email: String, password: String) async throws
    {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        try await authDataResult.user.sendEmailVerification()
    }

    /// Signs in a user asynchronously with email and password, checking email verification.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Throws: NSError if email not verified, or Firebase errors if sign-in fails.
    static func signInUser(email: String, password: String) async throws
    {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        guard authDataResult.user.emailVerified()
        else
        {
            throw NSError(
                domain: "Auth",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Email not verified. Please verify your email before signing in.",
                ],
            )
        }

        AuthenticationHelper.updateUserAuthStatus()
    }

    /// Signs in a user asynchronously using Google sign-in credentials.
    ///
    /// - Parameter googleSignInResult: The result from Google sign-in, containing ID token and access token.
    /// - Throws: Firebase authentication errors if sign-in fails.
    static func signInWithGoogle(googleSignInResult: GoogleSignInResult) async throws
    {
        let credential: AuthCredential = GoogleAuthProvider.credential(
            withIDToken: googleSignInResult.idToken,
            accessToken: googleSignInResult.accessToken,
        )
        try await Auth.auth().signIn(with: credential)

        AuthenticationHelper.updateUserAuthStatus()
    }

    /// Signs out the current user and updates auth status.
    ///
    /// - Throws: Firebase errors if sign-out fails.
    static func signOutUser() throws
    {
        try Auth.auth().signOut()
        AuthenticationHelper.updateUserAuthStatus()
    }

    /// Sends a password reset email to the specified address.
    ///
    /// - Parameter email: The email address to send the reset link to.
    static func sendForgetPasswordEmail(to email: String)
    {
        Auth.auth().sendPasswordReset(withEmail: email)
    }

    /// Deletes the current user's account asynchronously and updates auth status.
    ///
    /// - Throws: NSError if no user is logged in, or Firebase errors if deletion fails.
    static func deleteAccount() async throws
    {
        guard let user = Auth.auth().currentUser
        else
        {
            throw NSError(
                domain: "Auth",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "User not logged in. Please log in and try again.",
                ],
            )
        }

        try await user.delete()
        AuthenticationHelper.updateUserAuthStatus()
    }
}
