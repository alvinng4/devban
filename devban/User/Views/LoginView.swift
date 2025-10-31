import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: UserAuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Devban")
                .font(.largeTitle.bold())

            TextField("Username", text: $authVM.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("Password", text: $authVM.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            HStack {
                Button("Login") {
                    authVM.login()
                }
                .buttonStyle(.borderedProminent)

                Button("Register") {
                    authVM.register()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}