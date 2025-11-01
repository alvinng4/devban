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
    var dismiss: Bool = false

    func signUp()
    {
        invalidInputWarningString = ""
        showInvalidInputWarning = false
        emailVerificationString = ""
        showEmailVerificationString = false

        guard (!email.isEmptyOrWhitespace() && !password.isEmptyOrWhitespace())
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

                emailVerificationString = "Success! Please check your email address (\(email)) for verification email."
                showEmailVerificationString = true
            }
            catch
            {
                invalidInputWarningString = error.localizedDescription
                showInvalidInputWarning = true
            }
        }
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
}
