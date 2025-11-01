import SwiftUI

@main
struct devbanApp: App {
    @StateObject private var authVM = UserAuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authVM.isLoggedIn {
                MainView()
                    .environmentObject(authVM)
            } else {
                LoginViewWithRegisterOverlay()
                    .environmentObject(authVM)
            }
        }
    }
}

