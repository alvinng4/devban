import Firebase
import Foundation
import GoogleSignIn
import GoogleSignInSwift

@Observable
final class AuthenticationViewModel
{
    var email: String = ""
    var password: String = ""

    var isPresentErrorMessage: Bool = false
    var errorMessage: String = ""
    var isPresentSpecialMessage: Bool = false
    var specialMessage: String = ""
    var waitingServerResponse: Bool = false
    var dismiss: Bool = false
    var isPresentForgetPasswordAlert: Bool = false

    func signIn()
    {
        errorMessage = ""
        isPresentErrorMessage = false

        guard isInputValid()
        else
        {
            showErrorMessage("Invalid email or password")
            return
        }

        waitingServerResponse = true

        Task
        {
            do
            {
                try await AuthenticationHelper.signInUser(
                    email: email,
                    password: password,
                )
                waitingServerResponse = false
            }
            catch
            {
                waitingServerResponse = false
                showErrorMessage(error.localizedDescription)
            }
        }
    }
    
    func signInGoogle()
    {
        guard let clientID: String = FirebaseApp.app()?.options.clientID else { return }
        let helper: SignInWithGoogleHelper = SignInWithGoogleHelper(GIDClientID: clientID)

        Task
        {
            do
            {
                let signInResult: GoogleSignInResult = try await helper.signIn()
                try await AuthenticationHelper.signInWithGoogle(googleSignInResult: signInResult)
            }
            catch
            {
                showErrorMessage(error.localizedDescription)
            }
        }
    }

    func isInputValid() -> Bool
    {
        return !email.isEmptyOrWhitespace() && !password.isEmptyOrWhitespace()
    }

    func disableSubmit() -> Bool
    {
        return (
            !isInputValid()
                || waitingServerResponse,
        )
    }

    func forgetPassword()
    {
        isPresentForgetPasswordAlert = true
    }

    func confirmForgetPassword()
    {
        guard !email.isEmptyOrWhitespace()
        else
        {
            showErrorMessage("Failed to send reset password email. Reason: invalid email address.")
            return
        }

        AuthenticationHelper.sendForgetPasswordEmail(to: email)
        showSpecialMessage("A reset password email has been sent to your email address: \(email).")
    }

    private func showErrorMessage(_ message: String)
    {
        isPresentSpecialMessage = false
        specialMessage = ""
        errorMessage = message
        isPresentErrorMessage = true
    }

    private func showSpecialMessage(_ message: String)
    {
        isPresentErrorMessage = false
        errorMessage = ""
        specialMessage = message
        isPresentSpecialMessage = true
    }
}
