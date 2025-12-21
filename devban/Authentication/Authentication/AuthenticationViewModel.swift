import Firebase
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

extension AuthenticationView
{
    /// Enum representing types of messages displayed in the authentication UI.
    /// Used to categorize feedback like errors or status updates, affecting color and handling.
    enum MessageType
    {
        case normal
        case special
        case error
    }

    /// View model for managing authentication states and logic in AuthenticationView.
    ///
    /// This class handles user input validation, sign-in processes (email/password and Google),
    /// forget password requests, and UI feedback messages. It uses observables for reactive updates.
    ///
    /// ## Overview
    /// `AuthenticationViewModel` coordinates:
    /// - Input fields (email, password) with validation
    /// - Asynchronous sign-in tasks with error handling
    /// - Message display for user feedback
    /// - Alert triggers for forget password
    ///
    /// Properties are observable via @Observable for SwiftUI bindings.
    @Observable
    final class AuthenticationViewModel
    {
        /// The user's email address input.
        var email: String = ""

        /// The user's password input (secure field).
        var password: String = ""

        /// Flag indicating if a feedback message should be shown in the UI.
        private(set) var isShowMessage: Bool = false

        /// The current feedback message text.
        private(set) var message: String = ""

        /// The type of the current message, determining its color and style.
        private(set) var messageType: MessageType = .normal

        private var waitingServerResponse: Bool = false

        /// Exposed state for locking the whole page while waiting server response.
        /// (Use this in the View with .allowsHitTesting(!viewModel.isPageLocked) or .disabled(viewModel.isPageLocked))
        var isPageLocked: Bool
        {
            waitingServerResponse
        }

        /// Flag to present the forget password alert.
        var isPresentForgetPasswordAlert: Bool = false

        // MARK: - Sign In

        /// Initiates the email/password sign-in process asynchronously.
        /// Validates input, shows waiting message, and calls the helper for authentication.
        /// Updates UI states on success or error.
        func signIn()
        {
            guard !waitingServerResponse else { return } // Prevent double-tap / re-entry
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
                defer
                {
                    Task
                    { @MainActor in
                        self.waitingServerResponse = false
                    }
                }

                do
                {
                    try await AuthenticationHelper.signInUser(
                        email: email,
                        password: password,
                    )

                    await MainActor.run
                    {
                        self.showSpecialMessage("Success! Redirecting...")
                    }
                }
                catch
                {
                    await MainActor.run
                    {
                        self.showErrorMessage(error.localizedDescription)
                    }
                }
            }
        }

        /// Initiates the Google sign-in process asynchronously.
        /// Retrieves client ID, uses Google helper for sign-in, and authenticates with Firebase.
        /// Handles errors and updates UI feedback.
        func signInGoogle()
        {
            guard !waitingServerResponse else { return } // Prevent double-tap / re-entry
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
                defer
                {
                    Task
                    { @MainActor in
                        self.waitingServerResponse = false
                    }
                }

                do
                {
                    let signInResult: GoogleSignInResult = try await helper.signIn()
                    try await AuthenticationHelper.signInWithGoogle(googleSignInResult: signInResult)

                    await MainActor.run
                    {
                        self.showSpecialMessage("Success! Redirecting...")
                    }
                }
                catch
                {
                    await MainActor.run
                    {
                        self.showErrorMessage(error.localizedDescription)
                    }
                }
            }
        }

        // MARK: - Validation / UI State

        /// Checks if the email and password inputs are valid (non-empty and non-whitespace).
        func isInputValid() -> Bool
        {
            !email.isEmptyOrWhitespace() && !password.isEmptyOrWhitespace()
        }

        /// Determines if the sign-in submit button should be disabled.
        func disableSubmit() -> Bool
        {
            !isInputValid() || waitingServerResponse
        }

        // MARK: - Forget Password

        /// Triggers the forget password alert presentation.
        func forgetPassword()
        {
            guard !waitingServerResponse else { return } // Lock whole page behavior
            isPresentForgetPasswordAlert = true
        }

        /// Confirms and sends a password reset email if the email is valid.
        func confirmForgetPassword()
        {
            guard !waitingServerResponse else { return } // Lock whole page behavior

            guard !email.isEmptyOrWhitespace()
            else
            {
                showErrorMessage("Failed to send reset password email. Reason: invalid email address.")
                return
            }

            AuthenticationHelper.sendForgetPasswordEmail(to: email)
            showSpecialMessage("A reset password email has been sent to your email address: \(email).")
        }

        // MARK: - Message UI

        /// Computed property for the color of the feedback message based on its type.
        var messageColor: Color
        {
            switch messageType
            {
                case .normal:
                    return .primary
                case .special:
                    return ThemeManager.shared.buttonColor
                case .error:
                    return .red
            }
        }

        /// Resets the message states to hide feedback and default type.
        private func resetMessage()
        {
            isShowMessage = false
            messageType = .normal
            message = ""
        }

        /// Displays a normal (informational) message in the UI.
        private func showNormalMessage(_ msg: String)
        {
            messageType = .normal
            message = msg
            isShowMessage = true
        }

        /// Displays a special (success/emphasis) message in the UI.
        private func showSpecialMessage(_ msg: String)
        {
            messageType = .special
            message = msg
            isShowMessage = true
        }

        /// Displays an error message in the UI.
        private func showErrorMessage(_ msg: String)
        {
            messageType = .error
            message = msg
            isShowMessage = true
        }
    }
}
