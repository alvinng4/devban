import SwiftUI

/// Renders the user interface for Calendar.
///
/// This is the main calendar view that combines the calendar header, grid, and task list.
/// It manages the calendar view model and handles adding/editing tasks through navigation.
struct CalendarView: View
{
    /// Creates a new calendar view.
    ///
    /// Initializes the view with a new `CalendarViewModel` instance.
    init()
    {
        viewModel = CalendarViewModel()
    }

    /// The horizontal size class of the current environment.
    ///
    /// Used to adjust layout for compact (iPhone) vs regular (iPad) sizes.
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// The view model that manages calendar state and tasks.
    @State private var viewModel: CalendarViewModel

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
                    HStack
                    {
                        Text("Calendar")
                            .customTitle()

                        Spacer()

                        Button
                        {
                            navPath.append("New Task Deadline")
                        }
                        label:
                        {
                            Image(systemName: "plus")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(ThemeManager.shared.buttonColor)
                                .clipShape(Circle())
                        }
                    }

                    VStack(spacing: 0)
                    {
                        // MARK: Calendar Header with Navigation

                        CalendarHeaderView(
                            selectedDate: viewModel.selectedDate,
                            onPreviousMonth: { viewModel.previousMonth() },
                            onNextMonth: { viewModel.nextMonth() },
                            onToday: { viewModel.goToToday() },
                        )

                        Divider()
                            .foregroundStyle(.secondary)

                        // MARK: Calendar Grid

                        CalendarGridView(
                            selectedDate: $viewModel.selectedDate,
                            tasks: viewModel.tasks,
                        )

                        Divider()
                            .foregroundStyle(.secondary)

                        // MARK: Selected Date Tasks List

                        SelectedDateEventsView(
                            date: viewModel.selectedDate,
                            tasks: viewModel.selectedDateTasks,
                            navPath: $navPath,
                        )
                    }
                    .shadowedBorderRoundedRectangle()
                    .frame(maxHeight: .infinity, alignment: .center)
                }
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarHidden(true)
            .navigationDestination(for: DevbanTask.self)
            { devbanTask in
                DevbanTaskDetailView(devbanTask: devbanTask)
            }
            .navigationDestination(for: String.self)
            { string in
                if (string == "New Task Deadline")
                {
                    DevbanTaskAddView(status: .todo, deadline: viewModel.selectedDate)
                }
            }
        }
    }
}
