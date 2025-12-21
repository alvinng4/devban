import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

/// A view that handles user authentication, including email/password sign-in, Google sign-in, and password recovery.
///
/// `AuthenticationView` serves as the primary entry point for user login. It provides a structured interface
/// for users to enter credentials, navigate to sign-up, or recover forgotten passwords via an alert dialog.
///
/// ## Overview
/// The view is wrapped in a `NavigationStack` and utilizes a `ZStack` for background styling.
/// It delegates business logic, such as validation and API communication, to the `@State` managed
/// `AuthenticationViewModel`.
///
/// Key features include:
/// - Credential input (email/password)
/// - Email/password login and Google login
/// - Forget password via alert dialog
/// - Feedback messages
/// - Responsive padding based on size class
/// - Navigation to `SignUpView`
struct AuthenticationView: View
{
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// The view model that manages authentication states, input validation, and sign-in logic.
    @State private var viewModel: AuthenticationViewModel = .init()

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
                                } label: {
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
                        } label: {
                            Text("Sign In")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(
                                    viewModel.disableSubmit()
                                        ? Color.gray
                                        : ThemeManager.shared.buttonColor,
                                )
                                .cornerRadius(10)
                        }
                        .disabled(viewModel.disableSubmit())

                        if viewModel.isShowMessage
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
                    isCompact
                        ? NeobrutalismConstants.mainContentPaddingHorizontalCompact
                        : NeobrutalismConstants.mainContentPaddingHorizontalRegular,
                )
                .padding(
                    .vertical,
                    isCompact
                        ? NeobrutalismConstants.mainContentPaddingVerticalCompact
                        : NeobrutalismConstants.mainContentPaddingVerticalRegular,
                )
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden)
                .scrollContentBackground(.hidden)
                // Lock the entire page while waiting server response
                .allowsHitTesting(!viewModel.isPageLocked)

                // Overlay that blocks touches and shows loading
                if viewModel.isPageLocked
                {
                    Color.black
                        .opacity(0.001) // nearly invisible, but still blocks touches
                        .ignoresSafeArea()
                }
            }
            .alert(
                "Forget password?",
                isPresented: $viewModel.isPresentForgetPasswordAlert,
            )
            {
                TextField("Email address", text: $viewModel.email)
                    .autocorrectionDisabled(true)

                Button("Cancel", role: .cancel)
                {
                    viewModel.isPresentForgetPasswordAlert = false
                }

                Button("Confirm", role: .confirm)
                {
                    viewModel.confirmForgetPassword()
                    viewModel.isPresentForgetPasswordAlert = false
                }
            } message: {
                Text("A reset password email will be sent to your email address.")
            }
        }
    }
}

#Preview
{
    AuthenticationView()
}
