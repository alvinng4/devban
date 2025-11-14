import SwiftUI

struct MainView: View
{
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedTab: String = "home"

    var body: some View
    {
        let user: DevbanUser? = DevbanUserContainer.shared.user

        return getMainContent()
            .tint(ThemeManager.shared.buttonColor)
            .onAppear
            {
                AuthenticationHelper.updateUserAuthStatus()
                updateTheme()
            }
            .onChange(of: colorScheme)
            {
                updateTheme()
            }
            .onChange(of: DevbanUserContainer.shared.isLoggedIn)
            {
                updateTheme()
            }
            .preferredColorScheme(
                ThemeManager.getActualColorScheme(
                    preferredColorScheme: user?.preferredColorScheme ?? .auto,
                    colorScheme: colorScheme,
                ),
            )
    }

    private func getMainContent() -> some View
    {
        Group
        {
            if (!DevbanUserContainer.shared.isLoggedIn)
            {
                AuthenticationView()
            }
            else
            {
                TabView(
                    selection: $selectedTab,
                )
                {
                    HomeView()
                        .tabItem
                        {
                            Label("Home", systemImage: "house")
                        }
                        .tag("home")

                    CalendarView()
                        .tabItem
                        {
                            Label("Calendar", systemImage: "calendar")
                        }
                        .tag("calendar")

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
        }
    }

    private func updateTheme()
    {
        guard DevbanUserContainer.shared.isLoggedIn else { return }
        guard let user: DevbanUser = DevbanUserContainer.shared.user else { return }
        ThemeManager.shared.updateTheme(
            theme: user.theme,
            colorScheme: colorScheme,
            preferredColorScheme: user.preferredColorScheme,
        )
    }
}
