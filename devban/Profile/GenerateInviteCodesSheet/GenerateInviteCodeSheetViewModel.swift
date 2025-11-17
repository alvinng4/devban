import SwiftUI

extension GenerateInviteCodeSheetView
{
    /// Enum representing types of messages displayed in the UI.
    ///
    /// Used to categorize feedback like errors or status updates, affecting color and handling.
    enum MessageType
    {
        case normal
        case special
        case error
    }

    @Observable
    final class GenerateInviteCodeSheetViewModel
    {
        init()
        {
            self.role = DevbanUserContainer.shared.getUserTeamRole()
        }

        let role: DevbanTeam.Role?

        var numberOfCodesToBeGenerated: Int = 1

        /// The type of the current message, determining its color and style.
        private(set) var messageType: MessageType = .normal
        /// Flag indicating if a feedback message should be shown in the UI.
        private(set) var isShowMessage: Bool = false
        /// The current feedback message text.
        private(set) var message: String = ""

        private(set) var isSubmitSent: Bool = false
        private(set) var results: [String] = []

        func generateCode()
        {
            guard !disableSubmit
            else
            {
                showErrorMessage("Invalid input or permission!")
                return
            }

            showNormalMessage("Waiting server response...")

            Task
            {
                do
                {
                    for _ in 1 ... numberOfCodesToBeGenerated
                    {
                        let generatedId: String = try await DevbanTeamInviteCode.generateInviteCode()
                        results.append(generatedId)
                        isSubmitSent = true
                    }

                    showSpecialMessage("Success!")
                }
                catch
                {
                    showErrorMessage("Error: \(error.localizedDescription)")
                }
            }
        }

        /// Computed property to determine if the button should be disabled.
        ///
        /// - Returns: whether the button should be disabled.
        var disableSubmit: Bool
        {
            return (role != .admin) || isSubmitSent || (numberOfCodesToBeGenerated > 5) ||
                (numberOfCodesToBeGenerated <= 0)
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
