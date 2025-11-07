import SwiftUI

extension AccountDeletionSheetView
{
    /// Message types shown in the deletion sheet.
    enum MessageType
    {
        case normal, special, error
    }

    /// Handles input validation and account deletion logic.
    @Observable
    final class AccountDeletionSheetViewModel
    {
        /// User’s confirmation text
        var userInput: String = ""

        private(set) var messageType: MessageType = .normal
        private(set) var isShowMessage: Bool = false
        private(set) var message: String = ""

        /// Deletes account after user confirms with "YES"
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
                }
                catch
                {
                    showErrorMessage("Error: \(error.localizedDescription)")
                }
            }
        }

        /// True if user input is not "YES"
        var disableSubmit: Bool
        {
            return userInput != "YES"
        }

         /// Color for current message type
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
