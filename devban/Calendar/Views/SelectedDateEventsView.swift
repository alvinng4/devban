import SwiftUI

/// View showing events for the selected date.
///
/// This view displays a list of all events occurring on a specific date, with options to
/// toggle completion status, edit, or delete each event. If no events exist, it shows
/// an empty state message.
struct SelectedDateEventsView: View
{
    /// The date for which to display events.
    let date: Date

    /// The events to display for the selected date.
    let events: [CalendarEvent]

    /// Action to perform when toggling an event's completion status.
    let onToggleCompletion: (CalendarEvent) -> Void

    /// Action to perform when deleting an event.
    let onDelete: (CalendarEvent) -> Void

    /// Action to perform when editing an event.
    let onEdit: (CalendarEvent) -> Void

    /// Returns a formatted string representing the date.
    ///
    /// Format: "EEEE, MMMM d" (e.g., "Monday, January 15").
    ///
    /// - Returns: A formatted string with the day of week, month, and day.
    private var dateText: String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 12)
        {
            Text(dateText)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .padding(.horizontal)
                .padding(.top, 12)

            if events.isEmpty
            {
                VStack(spacing: 8)
                {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)

                    Text("No events scheduled")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            else
            {
                ScrollView
                {
                    VStack(spacing: 8)
                    {
                        ForEach(events)
                        { event in
                            EventRowView(
                                event: event,
                                onToggleCompletion: { onToggleCompletion(event) },
                                onDelete: { onDelete(event) },
                                onEdit: { onEdit(event) },
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
        }
    }
}
