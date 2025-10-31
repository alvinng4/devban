import SwiftUI

struct MainView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authVM: UserAuthViewModel

    var body: some View {
        NavigationView {
            VStack {
                AskLLMView()
            }
            .navigationTitle("Devban Chat")
            .toolbar {
                Button("Logout") {
                    authVM.logout()
                }
            }
            .onAppear {
                ThemeManager.shared.updateTheme(colorScheme: colorScheme)
            }
            .onChange(of: colorScheme) {
                ThemeManager.shared.updateTheme(colorScheme: colorScheme)
            }
        }
        .tint(ThemeManager.shared.buttonColor)
    }
}