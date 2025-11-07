import Firebase
import SwiftUI

extension SignUpView
{
    enum MessageType
    {
        case normal
        case special
        case error
    }

    @Observable
    final class SignUpViewModel
    {
        var email: String = ""
        var password: String = ""

        var isShowMessage: Bool = false
        var message: String = ""
        var messageType: MessageType = .normal

        var isPresentReturnAlert: Bool = false
        var waitingServerResponse: Bool = false
        var dismiss: Bool = false

        func signUp()
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
                    try await AuthenticationHelper.createUser(email: email, password: password)

                    waitingServerResponse = false
                    showSpecialMessage("Success! Please check your email address (\(email)) for verification email.")

                    email = ""
                    password = ""
                }
                catch
                {
                    waitingServerResponse = false
                    showErrorMessage(error.localizedDescription)
                }
            }
        }

        func signUpGoogle()
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

        func dismissOrShowAlert()
        {
            if (email.isEmptyOrWhitespace() && password.isEmptyOrWhitespace())
            {
                dismiss = true
            }
            else
            {
                isPresentReturnAlert = true
            }
        }

        func disableSubmit() -> Bool
        {
            return (
                !isInputValid()
                    || waitingServerResponse,
            )
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
