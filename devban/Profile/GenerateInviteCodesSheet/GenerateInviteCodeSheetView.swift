import SwiftUI

struct GenerateInviteCodeSheetView: View
{
    /// Dismiss action for the sheet, provided by SwiftUI environment.
    @Environment(\.dismiss) private var dismiss

    /// The view model that manages the logic and UI states.
    @State private var viewModel: GenerateInviteCodeSheetViewModel = .init()

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

            Text("Generate Invite Codes")
                .customTitle()

            VStack(spacing: 20)
            {
                Text("Please confirm the following details:")
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 15)
                {
                    HStack(spacing: 0)
                    {
                        Label("Team Name", systemImage: "person.2.circle")
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(DevbanUserContainer.shared.getTeamName() ?? "Error")
                    }

                    Divider()

                    HStack(spacing: 0)
                    {
                        Label("Number of codes", systemImage: "number.circle")
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Stepper(
                            "Number of codes",
                            value: $viewModel.numberOfCodesToBeGenerated,
                            in: 1 ... 5,
                        )
                        .labelsHidden()

                        Text("\(viewModel.numberOfCodesToBeGenerated)")
                            .padding(.horizontal)
                    }

                    Divider()

                    HStack
                    {
                        Label("Expiry (7 days)", systemImage: "calendar.badge.clock")
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(
                            Date().addingTimeInterval(86400 * 7).formatted(
                                date: .abbreviated,
                                time: .shortened,
                            ),
                        )
                    }
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.tertiary, lineWidth: 2),
                )

                Text(
                    """
                    Note: This action is only performable by \(Text("Admin").bold()).
                    Every code can be used once only.
                    """,
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                DisclosureGroup
                {
                    VStack
                    {
                        ForEach(viewModel.results.indices, id: \.self)
                        { resultIdx in
                            VStack(spacing: 5)
                            {
                                Divider()

                                HStack(spacing: 0)
                                {
                                    let inviteCode: String = viewModel.results[resultIdx]

                                    Text(inviteCode)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Button
                                    {
                                        TextEditingHelper.copyToClipboard(inviteCode)
                                    }
                                    label:
                                    {
                                        Image(systemName: "document.on.document")
                                            .textEditorToolBarButtonImage()
                                            .foregroundStyle(.gray)
                                            .padding(4)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .padding(.horizontal, 10)
                            }
                        }
                    }
                }
                label:
                {
                    Label("Results (\(viewModel.results.count))", systemImage: "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.tertiary, lineWidth: 2),
                )
                .foregroundStyle(.primary)

                Button
                {
                    viewModel.generateCode()
                }
                label:
                {
                    Text("Generate code")
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
