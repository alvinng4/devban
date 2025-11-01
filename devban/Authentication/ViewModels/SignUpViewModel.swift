import Foundation

@Observable
final class SignUpViewModel
{
    var email: String = ""
    var password: String = ""
    var showReturnAlert: Bool = false
    var showInvalidInputWarning: Bool = false
    var invalidInputWarningString: String = ""
    var showEmailVerificationString: Bool = false
    var emailVerificationString: String = ""
    var waitingServerResponse: Bool = false
    var dismiss: Bool = false

    func signUp()
    {
        waitingServerResponse = true
        invalidInputWarningString = ""
        showInvalidInputWarning = false
        emailVerificationString = ""
        showEmailVerificationString = false

        guard isInputValid()
        else
        {
            invalidInputWarningString = "Invalid email or password"
            showInvalidInputWarning = true
            return
        }

        Task
        {
            do
            {
                try await AuthenticationHelper.createUser(email: email, password: password)

                waitingServerResponse = false
                emailVerificationString = "Success! Please check your email address (\(email)) for verification email."
                showEmailVerificationString = true

                email = ""
                password = ""
            }
            catch
            {
                waitingServerResponse = false
                invalidInputWarningString = error.localizedDescription
                showInvalidInputWarning = true
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
            showReturnAlert = true
        }
    }

    func disableSubmit() -> Bool
    {
        return (
            !isInputValid()
                || waitingServerResponse,
        )
    }
}
