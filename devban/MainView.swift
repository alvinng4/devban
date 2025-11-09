import SwiftUI

struct MainView: View
{
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedTab: String = "askLLM"

    var body: some View
    {
        getMainContent()
            .tint(DevbanUser.shared.buttonColor)
            .onAppear
            {
                AuthenticationHelper.updateUserAuthStatus()

                DevbanUser.shared.updateTheme(colorScheme: colorScheme)
            }
            .onChange(of: colorScheme)
            {
                DevbanUser.shared.updateTheme(colorScheme: colorScheme)
            }
            .preferredColorScheme(DevbanUser.shared.getActualColorScheme(colorScheme))
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
