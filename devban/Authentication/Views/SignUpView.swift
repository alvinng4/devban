import SwiftUI

struct SignUpView: View
{
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showReturnAlert: Bool = false
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
                        dismissOrShowAlert()
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

                        TextField("Email address", text: $email)
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

                        SecureField("Password", text: $password)
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
                        print("Sign up")
                        DevbanUser.shared.loggedIn = true
                    }
                    label:
                    {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(ThemeManager.shared.buttonColor)
                            .cornerRadius(10)
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
            dismissOrShowAlert()
        }
        .alert("Return to last page?", isPresented: $showReturnAlert)
        {
            Button("Cancel", role: .cancel)
            {
                showReturnAlert = false
            }

            Button("Return", role: .destructive)
            {
                dismiss()
            }
        }
        message:
        {
            Text("The filled information will be lost.")
        }
    }

    private func dismissOrShowAlert()
    {
        if (email.isEmptyOrWhitespace() && password.isEmptyOrWhitespace())
        {
            dismiss()
        }
        else
        {
            showReturnAlert = true
        }
    }
}
