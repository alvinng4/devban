import Foundation

@Observable
final class SignUpViewModel
{
    var email: String = ""
    var password: String = ""

    var isPresentErrorMessage: Bool = false
    var errorMessage: String = ""
    var isPresentSpecialMessage: Bool = false
    var specialMessage: String = ""

    var isPresentReturnAlert: Bool = false
    var waitingServerResponse: Bool = false
    var dismiss: Bool = false

    func signUp()
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
