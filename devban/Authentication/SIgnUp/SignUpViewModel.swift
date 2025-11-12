import Firebase
import SwiftUI

extension SignUpView
{
    /// Enum representing types of messages displayed in the signup UI.
    ///
    /// Used to categorize feedback like errors or status updates, affecting color and handling.
    enum MessageType
    {
        case normal
        case special
        case error
    }

    /// View model for managing signup states and logic in SignUpView.
    ///
    /// This class handles user input validation, signup processes (email/password and Google),
    /// back navigation alerts, and UI feedback messages. It uses observables for reactive updates.
    ///
    /// ## Overview
    /// `SignUpViewModel` coordinates:
    /// - Input fields (email, password) with validation
    /// - Asynchronous signup tasks with error handling
    /// - Message display for user feedback
    /// - Alert triggers for unsaved changes on dismiss
    ///
    /// Properties are observable via @Observable for SwiftUI bindings.
    @Observable
    final class SignUpViewModel
    {
        /// The user's email address input.
        var email: String = ""
        /// The user's password input (secure field).
        var password: String = ""
        /// Flag indicating if a feedback message should be shown in the UI.
        var isShowMessage: Bool = false
        /// The current feedback message text.
        var message: String = ""
        /// The type of the current message, determining its color and style.
        var messageType: MessageType = .normal
        /// Flag to present the return confirmation alert.
        var isPresentReturnAlert: Bool = false
        /// Flag tracking if the view model is awaiting a server response.
        var waitingServerResponse: Bool = false
        /// Flag to dismiss the view after successful signup or confirmation.
        var dismiss: Bool = false
        /// Initiates the email/password signup process asynchronously.
        ///
        /// Validates input, shows waiting message, and calls the helper to create a user.
        /// Updates UI states on success (with verification email note) or error.
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

        /// Initiates the Google signup process asynchronously.
        ///
        /// Retrieves client ID, uses Google helper for signup, and authenticates with Firebase.
        /// Handles errors and updates UI feedback.
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

        /// Checks if the email and password inputs are valid (non-empty and non-whitespace).
        ///
        /// - Returns: True if both inputs are valid; false otherwise.
        func isInputValid() -> Bool
        {
            return !email.isEmptyOrWhitespace() && !password.isEmptyOrWhitespace()
        }

        /// Handles dismiss logic by checking for unsaved inputs and showing an alert if needed.
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

        /// Determines if the signup submit button should be disabled.
        ///
        /// - Returns: True if input is invalid or awaiting server response; false otherwise.
        func disableSubmit() -> Bool
        {
            return (
                !isInputValid()
                    || waitingServerResponse,
            )
        }

        /// Computed property for the color of the feedback message based on its type.
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
