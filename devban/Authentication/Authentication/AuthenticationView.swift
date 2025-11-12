import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

/// A view that handles user authentication, including email/password sign-in, Google sign-in, and forget password
/// functionality.
///
/// The view displays input fields, buttons, and feedback messages, with navigation to signup.
/// It is controlled by `AuthenticationViewModel`, which manages validation, API calls, and UI states.
///
/// ## Overview
/// `AuthenticationView` presents a full-screen authentication interface that includes:
/// - Email and password fields with validation
/// - Sign-in button and Google sign-in integration
/// - Forget password alert and signup link
/// - Dynamic feedback for errors or success
/// - Adaptive padding based on device size class

struct AuthenticationView: View
{
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// The view model that manages authentication states, input validation, and sign-in logic.
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
                            HStack(spacing: 0)
                            {
                                Text("Password")
                                    .fontDesign(.rounded)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)

                                Button
                                {
                                    viewModel.forgetPassword()
                                }
                                label:
                                {
                                    Text("Forget password?")
                                        .fontDesign(.rounded)
                                }
                            }

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

                        if (viewModel.isShowMessage)
                        {
                            Text(viewModel.message)
                                .foregroundStyle(viewModel.messageColor)
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
                            viewModel.signInGoogle()
                        }

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
        .alert("Forget password?", isPresented: $viewModel.isPresentForgetPasswordAlert)
        {
            Button("Cancel", role: .cancel)
            {
                viewModel.isPresentForgetPasswordAlert = false
            }

            Button("Confirm", role: .confirm)
            {
                viewModel.confirmForgetPassword()
                viewModel.isPresentForgetPasswordAlert = false
            }

            TextField("Email address", text: $viewModel.email)
                .autocorrectionDisabled(true)
        }
        message:
        {
            Text("A reset password email will be sent to your email address.")
        }
    }
}
