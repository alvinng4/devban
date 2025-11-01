import SwiftUI

struct LoginViewWithRegisterOverlay: View {
    @EnvironmentObject var authVM: UserAuthViewModel
    @State private var showRegister = false
    @State private var confirmPassword: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LoginViewContent()
                    .environmentObject(authVM)

                if showRegister {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation {
                                showRegister = false
                            }
                        }

                    VStack(spacing: 30) {
                        Text("Create Account")
                            .customTitle()
                            .multilineTextAlignment(.center)

                        VStack(spacing: 20) {
                            TextField("Username", text: $authVM.username)
                                .padding()
                                .shadowedBorderRoundedRectangle()
                                .autocapitalization(.none)
                                .disableAutocorrection(true)

                            SecureField("Password", text: $authVM.password)
                                .padding()
                                .shadowedBorderRoundedRectangle()

                            SecureField("Confirm Password", text: $confirmPassword)
                                .padding()
                                .shadowedBorderRoundedRectangle()
                        }

                        if let error = authVM.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        Button("Register") {
                            if authVM.registerToKeychain(confirmPassword: confirmPassword) {
                                withAnimation {
                                    showRegister = false
                                }
                            }
                        }
                        .buttonStyle(ShadowedBorderRoundedRectangleButtonStyle(stayPressed: true))

                    }
                    .padding(30)
                    .frame(maxWidth: 500)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow, lineWidth: 3)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.regularMaterial) 
                            )
                            .shadow(color: .yellow.opacity(0.4), radius: 8, x: 4, y: 4)
                    )
                    .padding(.horizontal, 40)
                    .transition(.opacity) 
                    .zIndex(1)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Register") {
                        withAnimation {
                            showRegister = true
                        }
                    }
                }
            }
        }
    }
}


struct LoginViewContent: View {
    @EnvironmentObject var authVM: UserAuthViewModel

    var body: some View {
        VStack(spacing: 50) {
            Spacer(minLength: 50)

            VStack(spacing: 20) {
                Text("Welcome Back to DevBan⚔️!")
                    .customTitle()
                    .multilineTextAlignment(.center)

                TextField("Username", text: $authVM.username)
                    .padding()
                    .shadowedBorderRoundedRectangle()
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                SecureField("Password", text: $authVM.password)
                    .padding()
                    .shadowedBorderRoundedRectangle()
            }
            .frame(maxWidth: 400)

            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 20) {
                Button("Login") {
                    authVM.login()
                }
                .buttonStyle(ShadowedBorderRoundedRectangleButtonStyle())
            }
            .frame(maxWidth: 400)

            Spacer()
        }
        .frame(maxWidth: NeobrutalismConstants.maxWidthLarge)
        .padding(.vertical, NeobrutalismConstants.mainContentPaddingVertical)
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}