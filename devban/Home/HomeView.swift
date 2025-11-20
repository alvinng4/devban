import SwiftUI

/// Renders the user interface for Home
struct HomeView: View
{
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var navPath: NavigationPath = .init()

    var body: some View
    {
        let isCompact: Bool = (horizontalSizeClass == .compact)

        NavigationStack(path: $navPath)
        {
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

                            NeobrutalismRoundedRectangleTabView(
                                options: ["Discussion"],
                                defaultSelection: "Discussion",
                            )
                            { _ in
                                DiscussionView()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                        .frame(maxWidth: 300)
                        .frame(maxHeight: .infinity, alignment: .top)

                        NeobrutalismRoundedRectangleTabView(
                            options: ["To-do"],
                            defaultSelection: "To-do",
                        )
                        { _ in
                            DevbanTaskListView(
                                status: .todo,
                                navPath: $navPath,
                            )
                        }
                        .frame(maxWidth: 300)
                        .frame(maxHeight: .infinity, alignment: .top)

                        NeobrutalismRoundedRectangleTabView(
                            options: ["In Progress"],
                            defaultSelection: "In Progress",
                        )
                        { _ in
                            DevbanTaskListView(
                                status: .inProgress,
                                navPath: $navPath,
                            )
                        }
                        .frame(maxWidth: 300)
                        .frame(maxHeight: .infinity, alignment: .top)

                        NeobrutalismRoundedRectangleTabView(
                            options: ["Done"],
                            defaultSelection: "Done",
                        )
                        { _ in
                            DevbanTaskListView(
                                status: .completed,
                                navPath: $navPath,
                            )
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
            .navigationBarHidden(true)
            .navigationDestination(for: DevbanTask.self)
            { devbanTask in
                DevbanTaskDetailView(devbanTask: devbanTask)
            }
            .navigationDestination(for: String.self)
            { string in
                if (string == "New Task Todo")
                {
                    DevbanTaskAddView(status: .todo)
                }
                else if (string == "New Task InProgress")
                {
                    DevbanTaskAddView(status: .inProgress)
                }
                else if (string == "New Task Completed")
                {
                    DevbanTaskAddView(status: .completed)
                }
            }
        }
    }
}
