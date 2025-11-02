import Foundation

@Observable
final class AuthenticationViewModel
{
    var email: String = ""
    var password: String = ""
    var showErrorMessage: Bool = false
    var errorMessage: String = ""
    var waitingServerResponse: Bool = false
    var dismiss: Bool = false
    var showForgetPasswordAlert: Bool = false
    var showSpecialMessage: Bool = false
    var specialMessage: String = ""

    func signIn()
    {
        errorMessage = ""
        showErrorMessage = false

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
        showForgetPasswordAlert = true
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
        showSpecialMessage = false
        specialMessage = ""
        errorMessage = message
        showErrorMessage = true
    }

    private func showSpecialMessage(_ message: String)
    {
        showErrorMessage = false
        errorMessage = ""
        specialMessage = message
        showSpecialMessage = true
    }
}
