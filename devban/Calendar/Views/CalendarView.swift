import SwiftUI

/// Renders the user interface for Calendar.
struct CalendarView: View
{
    init()
    {
        viewModel = CalendarViewModel()
    }

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var viewModel: CalendarViewModel
    @State private var showAddEventSheet: Bool = false
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
                if eventToEdit != nil && !showAddEventSheet
                {
                    showAddEventSheet = true
                }
            }
        }
    }
}
