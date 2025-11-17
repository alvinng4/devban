import SwiftUI

extension TeamCreateView
{
    /// Enum representing types of messages displayed in the authentication UI.
    /// Used to categorize feedback like errors or status updates, affecting color and handling.
    enum MessageType
    {
        case normal
        case special
        case error
    }

    @Observable
    final class TeamCreateViewModel
    {
        var teamName: String = ""
        var licenseID: String = ""

        /// Flag indicating if a feedback message should be shown in the UI.
        private(set) var isShowMessage: Bool = false
        /// The current feedback message text.
        private(set) var message: String = ""
        /// The type of the current message, determining its color and style.
        private(set) var messageType: MessageType = .normal
        private var waitingServerResponse: Bool = false

        func createTeam()
        {
            resetMessage()

            guard isInputValid()
            else
            {
                showErrorMessage("Invalid team name or license")
                return
            }

            waitingServerResponse = true
            showNormalMessage("Waiting server response...")

            Task
            {
                do
                {
                    // Get license
                    let license: License = try await License.getLicense(licenseID)

                    // If not exist, an error should be thrown. So at this point, the license exist
                    if (license.teamId != nil)
                    {
                        throw NSError(
                            domain: "Auth",
                            code: 401,
                            userInfo: [
                                NSLocalizedDescriptionKey:
                                    "The license is already used for other teams! Contact us if there is any issue.",
                            ],
                        )
                    }

                    guard let uid: String = DevbanUserContainer.shared.getUid()
                    else
                    {
                        throw NSError(
                            domain: "Auth",
                            code: 401,
                            userInfo: [
                                NSLocalizedDescriptionKey:
                                    "Failed to get user id! Please restart the app and try again.",
                            ],
                        )
                    }

                    // Create new team
                    let teamId: String = try await DevbanTeam.createNewTeamProfile(
                        teamName: teamName,
                        creatorUid: uid,
                        licenseId: license.id,
                    )

                    // Update license and also user
                    try await License.updateDatabaseData(
                        id: license.id,
                        data: ["team_id": teamId],
                    )
                    try await DevbanUser.updateDatabaseData(
                        uid: uid,
                        data: ["team_id": teamId],
                    )

                    // Update DevbanUserContainer
                    try await DevbanUserContainer.shared.setTeam(id: teamId)

                    waitingServerResponse = false
                    showSpecialMessage("Success! You should be navigated very soon...")
                }
                catch
                {
                    waitingServerResponse = false

                    // License key not found on database
                    if let decodingError = error as? DecodingError,
                       case .valueNotFound = decodingError
                    {
                        showErrorMessage("Invalid / missing License Key. Contact us if there is any issue.")
                    }
                    else
                    {
                        showErrorMessage(error.localizedDescription)
                    }
                }
            }
        }

        /// Checks if the inputs are valid (non-empty and non-whitespace).
        ///
        /// - Returns: True if all inputs are valid; false otherwise.
        func isInputValid() -> Bool
        {
            return !teamName.isEmptyOrWhitespace() && !licenseID.isEmptyOrWhitespace()
        }

        /// Determines if the submit button should be disabled.
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

        /// Resets the message states to hide feedback and default type.
        private func resetMessage()
        {
            isShowMessage = false
            messageType = .normal
            message = ""
        }

        /// Displays a normal (informational) message in the UI.
        ///
        /// - Parameter msg: The message text to show.
        private func showNormalMessage(_ msg: String)
        {
            messageType = .normal
            message = msg
            isShowMessage = true
        }

        /// Displays a special (success/emphasis) message in the UI.
        ///
        /// - Parameter msg: The message text to show.
        private func showSpecialMessage(_ msg: String)
        {
            messageType = .special
            message = msg
            isShowMessage = true
        }

        /// Displays an error message in the UI.
        ///
        /// - Parameter msg: The error message text to show.
        private func showErrorMessage(_ msg: String)
        {
            messageType = .error
            message = msg
            isShowMessage = true
        }
    }
}
