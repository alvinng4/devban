import SwiftUI

struct TeamJoinView: View
{
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var viewModel: TeamJoinViewModel = .init()

    @FocusState private var isTextFocused: Bool

    var body: some View
    {
        VStack(spacing: 20)
        {
            VStack(spacing: 4)
            {
                Text("Invite code")
                    .fontDesign(.rounded)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                TextField("Invite code", text: $viewModel.inviteCode)
                    .autocorrectionDisabled()
                    .font(.headline)
                    .focused($isTextFocused)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.tertiary, lineWidth: 1),
                    )
            }

            Button
            {
                viewModel.joinTeam()
            }
            label:
            {
                Text("Join team")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(
                        viewModel.disableSubmit() ?
                            Color.gray :
                            ThemeManager.shared.buttonColor,
                    )
                    .cornerRadius(10)
            }
            .disabled(viewModel.disableSubmit())

            if (viewModel.isShowMessage)
            {
                Text(viewModel.message)
                    .foregroundStyle(viewModel.messageColor)
            }

            Text("Tip: Ask your admin to generate an invite code")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(25)
    }
}
