import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

struct SignUpView: View
{
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var viewModel: SignUpViewModel = SignUpViewModel()

    @FocusState private var isTextFocused: Bool

    var body: some View
    {
        let isCompact: Bool = (horizontalSizeClass == .compact)

        ZStack
        {
            ThemeManager.shared.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 10)
            {
                // MARK: Tool bar

                HStack(spacing: 0)
                {
                    // Back button
                    Button
                    {
                        viewModel.dismissOrShowAlert()
                    }
                    label:
                    {
                        Image(systemName: "arrow.backward")
                            .toolBarButtonImage()
                    }
                    .buttonStyle(ShadowedBorderRoundedRectangleButtonStyle())

                    Spacer()
                }

                // MARK: Main content

                Text("Sign Up")
                    .customTitle()

                VStack(spacing: 20)
                {
                    VStack(spacing: 4)
                    {
                        Text("Email address")
                            .fontDesign(.rounded)
                            .frame(maxWidth: .infinity, alignment: .topLeading)

                        TextField("Email address", text: $viewModel.email)
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
                        viewModel.signUp()
                    }
                    label:
                    {
                        Text("Sign Up")
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

                    if (viewModel.waitingServerResponse)
                    {
                        Text("Waiting server response...")
                    }

                    if (viewModel.isPresentErrorMessage)
                    {
                        Text(viewModel.errorMessage)
                            .foregroundStyle(.red)
                    }

                    if (viewModel.isPresentSpecialMessage)
                    {
                        Text(viewModel.specialMessage)
                            .foregroundStyle(ThemeManager.shared.buttonColor)
                    }

                    Divider()

                    GoogleSignInButton(
                        viewModel: GoogleSignInButtonViewModel(
                            scheme: .dark,
                            style: .wide,
                            state: .normal,
                        ),
                    )
                    {
                        viewModel.signUpGoogle()
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
        .onBackSwipe
        {
            viewModel.dismissOrShowAlert()
        }
        .alert("Return to last page?", isPresented: $viewModel.isPresentReturnAlert)
        {
            Button("Cancel", role: .cancel)
            {
                viewModel.isPresentReturnAlert = false
            }

            Button("Return", role: .destructive)
            {
                viewModel.email = ""
                viewModel.password = ""
                viewModel.dismiss = false
                dismiss()
            }
        }
        message:
        {
            Text("The filled information will be lost.")
        }
        .onChange(of: viewModel.dismiss)
        {
            if (viewModel.dismiss)
            {
                viewModel.email = ""
                viewModel.password = ""
                viewModel.dismiss = false
                dismiss()
            }
        }
    }
}
