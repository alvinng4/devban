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

    func signIn()
    {
        errorMessage = ""
        showErrorMessage = false

        guard isInputValid()
        else
        {
            errorMessage = "Invalid email or password"
            showErrorMessage = true
            return
        }

        waitingServerResponse = true

        Task
        {
            do
            {
                let authDataResult: AuthDataResultModel = try await AuthenticationHelper.signInUser(
                    email: email,
                    password: password,
                )
                DevbanUser.shared.loginUser(with: authDataResult)
                waitingServerResponse = false
            }
            catch
            {
                waitingServerResponse = false
                errorMessage = error.localizedDescription
                showErrorMessage = true
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
}
