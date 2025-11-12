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

                ThemeManager.shared.updateTheme(
                    theme: DevbanUser.shared.theme,
                    colorScheme: colorScheme,
                    preferredColorScheme: DevbanUser.shared.preferredColorScheme,
                )
            }
            .onChange(of: colorScheme)
            {
                ThemeManager.shared.updateTheme(
                    theme: DevbanUser.shared.theme,
                    colorScheme: colorScheme,
                    preferredColorScheme: DevbanUser.shared.preferredColorScheme,
                )
            }
            .preferredColorScheme(
                ThemeManager.shared.getActualColorScheme(
                    preferredColorScheme: DevbanUser.shared.preferredColorScheme,
                    colorScheme: colorScheme,
                ),
            )
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
            else
            {
                AuthenticationView()
            }
        }
    }
}
