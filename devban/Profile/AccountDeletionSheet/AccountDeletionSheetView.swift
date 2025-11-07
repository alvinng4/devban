import SwiftUI

struct AccountDeletionSheetView: View
{
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: AccountDeletionSheetViewModel = AccountDeletionSheetViewModel()
    @FocusState private var isTextFocused: Bool

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
                                ThemeManager.shared.buttonColor,
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
