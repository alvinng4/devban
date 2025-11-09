import SwiftUI

/// A view that presents a confirmation sheet for permanent account deletion.
///
/// The sheet asks the user to confirm by typing "YES" before allowing deletion.
/// It provides user feedback messages and disables the delete button until
/// the confirmation input is valid.
///
/// ## Overview
/// `AccountDeletionSheetView` displays a modal confirmation dialog that includes:
/// - A dismiss button
/// - A confirmation text field
/// - A delete action button
/// - Optional feedback message after the delete attempt
///
/// This view is controlled by `AccountDeletionSheetViewModel`,
/// which handles input validation and the deletion logic.
struct AccountDeletionSheetView: View
{
    /// Dismiss action for the sheet, provided by SwiftUI environment.
    @Environment(\.dismiss) private var dismiss

    /// The view model that manages the account deletion logic and UI states.
    @State private var viewModel: AccountDeletionSheetViewModel = AccountDeletionSheetViewModel()

    /// Tracks whether the confirmation text field is currently focused.
    @FocusState private var isTextFocused: Bool

    /// The main content of the account deletion confirmation sheet.
    var body: some View
    {
        VStack(spacing: 20)
        {
            Button(role: .cancel)
            {
                dismiss()
            }
            label:
            {
                Text("Dismiss")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text("Delete Account")
                .customTitle()

            VStack(spacing: 20)
            {
                Text(
                    """
                    Are you sure you want to delete your account? It is permanant and cannot be undone.

                    If yes, enter \"YES\" then click confirm.
                    """,
                )

                TextField("Confirm Message", text: $viewModel.userInput)
                    .autocorrectionDisabled()
                    .font(.headline)
                    .focused($isTextFocused)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.tertiary, lineWidth: 1),
                    )

                Button
                {
                    viewModel.deleteAccount()
                }
                label:
                {
                    Text("Delete Account")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            viewModel.disableSubmit ?
                                Color.gray :
                                DevbanUser.shared.buttonColor,
                        )
                        .cornerRadius(10)
                }
                .disabled(viewModel.disableSubmit)

                if (viewModel.isShowMessage)
                {
                    Text(viewModel.message)
                        .foregroundStyle(viewModel.messageColor)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .padding()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
