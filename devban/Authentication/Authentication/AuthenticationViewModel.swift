import Firebase
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

extension AuthenticationView
{
    enum MessageType
    {
        case normal
        case special
        case error
    }

    @Observable
    final class AuthenticationViewModel
    {
        var email: String = ""
        var password: String = ""

        private(set) var isShowMessage: Bool = false
        private(set) var message: String = ""
        private(set) var messageType: MessageType = .normal
        private var waitingServerResponse: Bool = false

        var dismiss: Bool = false
        var isPresentForgetPasswordAlert: Bool = false

        func signIn()
        {
            resetMessage()

            guard isInputValid()
            else
            {
                showErrorMessage("Invalid email or password")
                return
            }

            waitingServerResponse = true
            showNormalMessage("Waiting server response...")

            Task
            {
                do
                {
                    try await AuthenticationHelper.signInUser(
                        email: email,
                        password: password,
                    )
                    waitingServerResponse = false
                    resetMessage()
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
            resetMessage()

            guard let clientID: String = FirebaseApp.app()?.options.clientID
            else
            {
                showErrorMessage("Error: ClientID not found. Please try again.")
                return
            }
            let helper: SignInWithGoogleHelper = SignInWithGoogleHelper(GIDClientID: clientID)

            waitingServerResponse = true
            showNormalMessage("Waiting server response...")

            Task
            {
                do
                {
                    let signInResult: GoogleSignInResult = try await helper.signIn()
                    try await AuthenticationHelper.signInWithGoogle(googleSignInResult: signInResult)
                    waitingServerResponse = false
                    resetMessage()
                }
                catch
                {
                    waitingServerResponse = false
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

        var messageColor: Color
        {
            switch (messageType)
            {
                case .normal:
                    return .primary
                case .special:
                    return ThemeManager.shared.buttonColor
                case .error:
                    return .red
            }
        }

        private func resetMessage()
        {
            isShowMessage = false
            messageType = .normal
            message = ""
        }

        private func showNormalMessage(_ msg: String)
        {
            messageType = .normal
            message = msg
            isShowMessage = true
        }

        private func showSpecialMessage(_ msg: String)
        {
            messageType = .special
            message = msg
            isShowMessage = true
        }

        private func showErrorMessage(_ msg: String)
        {
            messageType = .error
            message = msg
            isShowMessage = true
        }
    }
}
