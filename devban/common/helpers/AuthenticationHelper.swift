import FirebaseAuth
import Foundation

enum AuthenticationHelper
{
    static func updateUserAuthStatus()
    {
        guard let user = Auth.auth().currentUser,
              user.emailVerified()
        else
        {
            DevbanUser.shared.logoutUser()
            return
        }

        DevbanUser.shared.loginUser(
            with: AuthDataResultModel(user: user),
        )
    }

    static func createUser(email: String, password: String) async throws
    {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        try await authDataResult.user.sendEmailVerification()
    }

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

    static func signOutUser() throws
    {
        try Auth.auth().signOut()
        AuthenticationHelper.updateUserAuthStatus()
    }

    static func sendForgetPasswordEmail(to email: String)
    {
        Auth.auth().sendPasswordReset(withEmail: email)
    }
}
