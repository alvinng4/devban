import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authVM: UserAuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var confirmPassword: String = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Username", text: $authVM.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            SecureField("Password", text: $authVM.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            Button("Register") {
                if authVM.registerToKeychain(confirmPassword: confirmPassword) {
                    dismiss() 
                }
            }
            .padding()
        }
        .padding()
        .navigationTitle("Register")
    }
}