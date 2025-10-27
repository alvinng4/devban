import SwiftUI

struct MainView: View
{
    @Environment(\.colorScheme) private var colorScheme

    var body: some View
    {
        mainContent
            // Theme
            .onAppear
            {
                ThemeManager.shared.updateTheme(colorScheme: colorScheme)
            }
            .onChange(of: colorScheme)
            {
                ThemeManager.shared.updateTheme(colorScheme: colorScheme)
            }
    }

    private var mainContent: some View
    {
        AskLLMView()
            .tint(ThemeManager.shared.buttonColor)
    }
}
