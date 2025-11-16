import SwiftUI

struct MainView: View
{
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedTab: String = "home"
    @State private var isInitialized: Bool = false

    var body: some View
    {
        if (!isInitialized)
        {
            return AnyView(
                ZStack
                {
                    Color(.darkBackground)
                        .ignoresSafeArea()

                    ProgressView()
                        .tint(.white)
                }
                .task
                {
                    await AuthenticationHelper.updateUserAuthStatus()
                    updateTheme()
                    isInitialized = true
                },
            )
        }
        else
        {
            return AnyView(
                getMainContent()
                    .tint(ThemeManager.shared.buttonColor)
                    .onChange(of: colorScheme)
                    {
                        updateTheme()
                    }
                    .onChange(of: DevbanUserContainer.shared.loggedIn)
                    {
                        updateTheme()
                    }
                    .preferredColorScheme(
                        ThemeManager.getActualColorScheme(
                            preferredColorScheme: DevbanUserContainer.shared.getPreferredColorScheme(),
                            colorScheme: colorScheme,
                        ),
                    ),
            )
        }
    }

    private func getMainContent() -> some View
    {
        Group
        {
            if (!DevbanUserContainer.shared.loggedIn)
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
        ThemeManager.shared.updateTheme(
            theme: DevbanUserContainer.shared.getTheme(),
            colorScheme: colorScheme,
            preferredColorScheme: DevbanUserContainer.shared.getPreferredColorScheme(),
        )
    }
}
