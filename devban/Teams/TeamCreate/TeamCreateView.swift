import SwiftUI

struct TeamCreateView: View
{
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var viewModel: TeamCreateViewModel = .init()

    @FocusState private var isTextFocused: Bool

    var body: some View
    {
        VStack(spacing: 20)
        {
            VStack(spacing: 4)
            {
                Text("Team name")
                    .fontDesign(.rounded)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                TextField("Team name", text: $viewModel.teamName)
                    .autocorrectionDisabled()
                    .font(.headline)
                    .focused($isTextFocused)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.tertiary, lineWidth: 1),
                    )
            }

            VStack(spacing: 4)
            {
                Text("License Key")
                    .fontDesign(.rounded)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                TextField("License Key", text: $viewModel.licenseID)
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
                viewModel.createTeam()
            }
            label:
            {
                Text("Create team")
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

            HStack
            {
                Text("Don't have a license key?")

                Link(destination: URL(string: "mailto:QuestList_app@outlook.com")!)
                {
                    Text("Contact us")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(25)
    }
}
