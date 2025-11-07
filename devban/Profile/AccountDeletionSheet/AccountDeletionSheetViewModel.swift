import SwiftUI

extension AccountDeletionSheetView
{
    enum MessageType
    {
        case normal
        case special
        case error
    }

    @Observable
    final class AccountDeletionSheetViewModel
    {
        var userInput: String = ""

        private(set) var messageType: MessageType = .normal
        private(set) var isShowMessage: Bool = false
        private(set) var message: String = ""

        var disableSubmit: Bool
        {
            return userInput != "YES"
        }

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
