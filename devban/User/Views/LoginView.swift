import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: UserAuthViewModel
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Username", text: $authVM.username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                SecureField("Password", text: $authVM.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if let error = authVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
                
                Button("Login") {
                    authVM.login()
                }
                .padding()
                
                Button("Register") {
                    showRegister = true
                }
                .padding()
                .foregroundColor(.blue)
                
            }
            .padding()
            .navigationTitle("Login")
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
                    .environmentObject(authVM)
            }
        }
    }
}