import Foundation

@Observable
final class AuthenticationViewModel
{
    var email: String = ""
    var password: String = ""
    var showErrorMessage: Bool = false
    var errorMessage: String = ""
    var dismiss: Bool = false

    func signIn()
    {
        errorMessage = ""
        showErrorMessage = false

        guard (!email.isEmptyOrWhitespace() && !password.isEmptyOrWhitespace())
        else
        {
            errorMessage = "Invalid email or password"
            showErrorMessage = true
            return
        }

        Task
        {
            do
            {
                let authDataResult: AuthDataResultModel = try await AuthenticationHelper.signInUser(
                    email: email,
                    password: password,
                )
                DevbanUser.shared.loginUser(with: authDataResult)
            }
            catch
            {
                errorMessage = error.localizedDescription
                showErrorMessage = true
            }
        }
    }
}
