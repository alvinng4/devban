import SwiftUI

struct AuthenticationView: View
{
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var viewModel: AuthenticationViewModel = AuthenticationViewModel()

    @FocusState private var isTextFocused: Bool

    var body: some View
    {
        let isCompact: Bool = (horizontalSizeClass == .compact)

        NavigationStack
        {
            ZStack
            {
                ThemeManager.shared.backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 10)
                {
                    Text("Sign In")
                        .customTitle()

                    VStack(spacing: 20)
                    {
                        VStack(spacing: 4)
                        {
                            Text("Email address")
                                .fontDesign(.rounded)
                                .frame(maxWidth: .infinity, alignment: .topLeading)

                            TextField("Email address", text: $viewModel.email)
                                .autocorrectionDisabled(true)
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
                            Text("Password")
                                .fontDesign(.rounded)
                                .frame(maxWidth: .infinity, alignment: .topLeading)

                            SecureField("Password", text: $viewModel.password)
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
                            viewModel.signIn()
                        }
                        label:
                        {
                            Text("Sign In")
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

                        if (viewModel.showErrorMessage)
                        {
                            Text(viewModel.errorMessage)
                                .foregroundStyle(.red)
                        }

                        Divider()

                        HStack
                        {
                            Text("New User?")

                            NavigationLink(destination: SignUpView())
                            {
                                Text("Create an account")
                            }
                        }
                    }
                    .padding(25)
                    .shadowedBorderRoundedRectangle()
                }
                .frame(maxWidth: NeobrutalismConstants.maxWidthSmall)
                .padding(
                    .horizontal,
                    isCompact ?
                        NeobrutalismConstants.mainContentPaddingHorizontalCompact :
                        NeobrutalismConstants.mainContentPaddingHorizontalRegular,
                )
                .padding(
                    .vertical,
                    isCompact ?
                        NeobrutalismConstants.mainContentPaddingVerticalCompact :
                        NeobrutalismConstants.mainContentPaddingVerticalRegular,
                )
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden)
                .scrollContentBackground(.hidden)
            }
        }
    }
}
