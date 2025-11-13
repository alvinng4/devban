import SwiftUI

/// Renders the user interface for Calendar.
///
/// This is the main calendar view that combines the calendar header, grid, and event list.
/// It manages the calendar view model and handles adding/editing events through a sheet presentation.
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

    /// The view model that manages calendar state and events.
    @State private var viewModel: CalendarViewModel

    /// Whether the add/edit event sheet is currently presented.
    @State private var showAddEventSheet: Bool = false

    /// The event to edit, or `nil` if creating a new event.
    @State private var eventToEdit: CalendarEvent?

    var body: some View
    {
        let isCompact: Bool = (horizontalSizeClass == .compact)

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
                        eventToEdit = nil
                        showAddEventSheet = true
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
                        events: viewModel.events,
                    )

                    Divider()
                        .foregroundStyle(.secondary)

                    // MARK: Selected Date Events List

                    SelectedDateEventsView(
                        date: viewModel.selectedDate,
                        events: viewModel.selectedDateEvents,
                        onToggleCompletion: { event in viewModel.toggleEventCompletion(event) },
                        onDelete: { event in viewModel.deleteEvent(event) },
                        onEdit: { event in
                            eventToEdit = event
                            showAddEventSheet = true
                        },
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
            .sheet(isPresented: $showAddEventSheet)
            {
                AddEventView(
                    viewModel: viewModel,
                    eventToEdit: eventToEdit,
                )
                .onDisappear
                {
                    eventToEdit = nil
                }
            }
            .onChange(of: eventToEdit)
            {
                if eventToEdit != nil, !showAddEventSheet
                {
                    showAddEventSheet = true
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
