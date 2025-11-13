import SwiftUI

/// Renders the user interface for Home
struct HomeView: View
{
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View
    {
        let isCompact: Bool = (horizontalSizeClass == .compact)

        ZStack
        {
            ThemeManager.shared.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 10)
            {
                HStack(spacing: 25)
                {
                    VStack(spacing: 10)
                    {
                        UserGamificationBarView()

                        Text("Notifications")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .frame(height: 350)
                            .shadowedBorderRoundedRectangle()

                        Text("Tags")
                            .customTitle()

                        Text("Tags")
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .shadowedBorderRoundedRectangle()
                    }
                    .frame(maxWidth: 300)
                    .frame(maxHeight: .infinity, alignment: .top)

                    NeobrutalismRoundedRectangleTabView(
                        options: ["To-do"],
                        defaultSelection: "To-do",
                    )
                    { _ in
                        Text("Hello, world!")
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .frame(maxWidth: 300)
                    .frame(maxHeight: .infinity, alignment: .top)

                    NeobrutalismRoundedRectangleTabView(
                        options: ["In Progress"],
                        defaultSelection: "In Progress",
                    )
                    { _ in
                        Text("Hello, world!")
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .frame(maxWidth: 300)
                    .frame(maxHeight: .infinity, alignment: .top)

                    NeobrutalismRoundedRectangleTabView(
                        options: ["Done"],
                        defaultSelection: "Done",
                    )
                    { _ in
                        Text("Hello, world!")
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .frame(maxWidth: 300)
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            .frame(maxWidth: NeobrutalismConstants.maxWidthExtraLarge)
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
