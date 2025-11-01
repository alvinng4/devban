import SwiftUI

struct MainView: View
{
    @Environment(\.colorScheme) private var colorScheme

    var body: some View
    {
        getMainContent()
            // Theme
            .tint(ThemeManager.shared.buttonColor)
            .onAppear
            {
                ThemeManager.shared.updateTheme(colorScheme: colorScheme)
            }
            .onChange(of: colorScheme)
            {
                ThemeManager.shared.updateTheme(colorScheme: colorScheme)
            }
    }

    private func getMainContent() -> some View
    {
        Group
        {
            if (DevbanUser.shared.loggedIn)
            {
                AskLLMView()
            }
            else
            {
                AuthenticationView()
            }
        }
    }
}
