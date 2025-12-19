import SwiftUI

extension AccountDeletionSheetView
{
    /// Enum representing types of messages displayed in the account deletion UI.
    ///
    /// Used to categorize feedback like errors or status updates, affecting color and handling.
    enum MessageType
    {
        case normal
        case special
        case error
    }

    /// View model for managing the account deletion confirmation sheet's states and logic.
    ///
    /// This class handles user input validation ("YES" confirmation), deletion calls, and UI feedback messages.
    /// It uses observables for reactive updates in the sheet view.
    ///
    /// ## Overview
    /// `AccountDeletionSheetViewModel` coordinates:
    /// - Confirmation input field with validation
    /// - Asynchronous deletion task with error handling
    /// - Message display for user feedback (normal, special, error)
    ///
    /// Properties are observable via @Observable for SwiftUI bindings.
    @Observable
    final class AccountDeletionSheetViewModel
    {
        /// The user's confirmation input (must be "YES" to enable deletion).
        var userInput: String = ""
        /// The type of the current message, determining its color and style.
        private(set) var messageType: MessageType = .normal
        /// Flag indicating if a feedback message should be shown in the UI.
        private(set) var isShowMessage: Bool = false
        /// The current feedback message text.
        private(set) var message: String = ""
        /// Initiates the account deletion process asynchronously if input is valid.
        ///
        /// Validates "YES" input, shows waiting message, and calls the helper for deletion.
        /// Updates UI states on success or error.
        func deleteAccount()
        {
            guard !disableSubmit
            else
            {
                showErrorMessage("Invalid input!")
                return
            }

            showNormalMessage("Waiting server response...")

            Task
            {
                do
                {
                    try await AuthenticationHelper.deleteAccount()
                    showSpecialMessage("Done! Your account is deleted.")
                    try await Task.sleep(for: .seconds(1))
                }
                catch
                {
                    showErrorMessage("Error: \(error.localizedDescription)")
                }
            }
        }

        /// Computed property to determine if the delete button should be disabled.
        ///
        /// - Returns: True if user input is not "YES"; false otherwise.
        var disableSubmit: Bool
        {
            return userInput != "YES"
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
