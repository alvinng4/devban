import FirebaseAuth
import Foundation

enum AuthenticationHelper
{
    static func initializeUser()
    {
        guard let user = Auth.auth().currentUser else { return }
        guard user.emailVerified() else { return }

        DevbanUser.shared.loginUser(
            with: AuthDataResultModel(user: user),
        )
    }

    static func createUser(email: String, password: String) async throws
    {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        try await authDataResult.user.sendEmailVerification()
    }

    static func signInUser(email: String, password: String) async throws -> AuthDataResultModel
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

        return AuthDataResultModel(user: authDataResult.user)
    }
}
