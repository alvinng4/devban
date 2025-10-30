import SwiftUI

struct MainView: View
{
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View
    {
        getMainContent()
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

    private func getMainContent() -> some View
    {
        let isCompact: Bool = (horizontalSizeClass == .compact)

        return ZStack
        {
            ThemeManager.shared.backgroundColor
                .ignoresSafeArea()

            AskLLMView()
                .tint(ThemeManager.shared.buttonColor)
                .frame(maxWidth: NeobrutalismConstants.maxWidthLarge)
                .padding(
                    .horizontal,
                    isCompact ?
                        NeobrutalismConstants.mainContentPaddingHorizontalCompact :
                        NeobrutalismConstants.mainContentPaddingHorizontalRegular,
                )
                .padding(
                    .vertical,
                    isCompact ?
                        NeobrutalismConstants.mainContentPaddingVerticalCompact :
                        NeobrutalismConstants.mainContentPaddingVerticalRegular,
                )
        }
    }
}
