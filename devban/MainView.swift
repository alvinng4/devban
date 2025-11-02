import SwiftUI

struct MainView: View
{
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedTab: String = "askLLM"

    var body: some View
    {
        getMainContent()
            .tint(ThemeManager.shared.buttonColor)
            .onAppear
            {
                AuthenticationHelper.updateUserAuthStatus()

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
                TabView(
                    selection: $selectedTab,
                )
                {
                    AskLLMView()
                        .tabItem
                        {
                            Label("AskLLM", systemImage: "apple.intelligence")
                        }
                        .tag("askLLM")

                    ProfileView()
                        .tabItem
                        {
                            Label("Profile", systemImage: "person.crop.circle")
                        }
                        .tag("profile")
                }
            }
            else
            {
                AuthenticationView()
            }
        }
    }
}
