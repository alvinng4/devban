import SwiftUI

struct MainView: View
{
    @Environment(\.colorScheme) private var colorScheme

    var body: some View
    {
        getMainContent()
            .tint(ThemeManager.shared.buttonColor)
            .onAppear
            {
                AuthenticationHelper.initializeUser()

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
                NeobrutalismRoundedRectangleTabView(
                    options: ["AskLLM", "Calendar"],
                    defaultSelection: "AskLLM",
                )
                { option in
                    Group
                    {
                        if option == "AskLLM"
                        {
                            AskLLMView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        else
                        {
                            CalendarView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
            }
            else
            {
                AuthenticationView()
            }
        }
    }
}
