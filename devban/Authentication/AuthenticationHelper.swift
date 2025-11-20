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
    static func updateUserAuthStatus() async
    {
        // Reload user status
        guard let tempUser = Auth.auth().currentUser
        else
        {
            DevbanUserContainer.shared.logoutUser()
            return
        }

        do
        {
            try await tempUser.reload()
        }
        catch
        {
            print("AuthenticationHelper.updateUserAuthStatus() reloading user error: \(error.localizedDescription)")
        }

        // Get updated user status and check if email verified
        guard let user = Auth.auth().currentUser,
              user.emailVerified()
        else
        {
            DevbanUserContainer.shared.logoutUser()
            return
        }

        // Update user last access status to database
        do
        {
            try await DevbanUser.updateUserStatusToDatabase(uid: user.uid)
        }
        catch
        {
            print(
                "updateUserAuthStatus() create user profile on database error: \(error.localizedDescription)",
            )
        }

        // Login user if all succeed
        do
        {
            try await DevbanUserContainer.shared.loginUser(with: user)
        }
        catch
        {
            print("updateUserAuthStatus() failed to login: \(error.localizedDescription)")
        }
    }

    /// Creates a new user asynchronously with email and password, then sends a verification email.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - displayName: The user's display name.
    ///   - password: The user's password.
    /// - Throws: Firebase authentication errors if creation or email sending fails.
    static func createUser(email: String, displayName: String, password: String) async throws
    {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        try await authDataResult.user.sendEmailVerification()

        // Update user's display name
        let changeRequest = authDataResult.user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()

        // Create user on database
        try await DevbanUser.createNewUserProfile(uid: authDataResult.user.uid, displayName: displayName)
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

        await AuthenticationHelper.updateUserAuthStatus()
    }

    /// Signs up a user asynchronously using Google sign-in credentials.
    ///
    /// - Parameter googleSignInResult: The result from Google sign-in, containing ID token and access token.
    /// - Throws: Firebase authentication errors if sign-in fails.
    static func signUpWithGoogle(googleSignInResult: GoogleSignInResult) async throws
    {
        let credential: AuthCredential = GoogleAuthProvider.credential(
            withIDToken: googleSignInResult.idToken,
            accessToken: googleSignInResult.accessToken,
        )
        try await Auth.auth().signIn(with: credential)

        guard let user = Auth.auth().currentUser
        else
        {
            try await AuthenticationHelper.signOutUser()
            throw NSError(
                domain: "Auth",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Failed to create user profile on database. Please try again.",
                ],
            )
        }

        try await DevbanUser.createNewUserProfile(uid: user.uid, displayName: user.displayName)
        await AuthenticationHelper.updateUserAuthStatus()
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
        await AuthenticationHelper.updateUserAuthStatus()
    }

    /// Signs out the current user and updates auth status.
    ///
    /// - Throws: Firebase errors if sign-out fails.
    static func signOutUser() async throws
    {
        try Auth.auth().signOut()
        await AuthenticationHelper.updateUserAuthStatus()
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

        guard let teamID = DevbanUserContainer.shared.getTeamId()
        else
        {
            throw NSError(
                domain: "Auth",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Failed to get team information.",
                ],
            )
        }

        try await user.delete()
        try await DevbanUser.deleteUser(uid: user.uid)
        try await DevbanTeam.deleteUser(teamId: teamID, uid: user.uid)
        await AuthenticationHelper.updateUserAuthStatus()
    }
}
