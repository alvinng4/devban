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
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
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
        .frame(maxHeight: 200)
    }
}

/// Individual event row view.
///
/// This view displays a single event in the events list, showing its title, optional time,
/// completion status, and action menu for editing or deleting.
struct EventRowView: View
{
    /// The event to display.
    let event: CalendarEvent

    /// Action to perform when toggling the event's completion status.
    let onToggleCompletion: () -> Void

    /// Action to perform when deleting the event.
    let onDelete: () -> Void

    /// Action to perform when editing the event.
    let onEdit: () -> Void

    /// Returns a formatted string representing the event's start time.
    ///
    /// Returns `nil` if the event has no start time.
    ///
    /// - Returns: A formatted time string (e.g., "3:00 PM"), or `nil` if no start time exists.
    private var timeText: String?
    {
        guard let startTime = event.startTime else { return nil }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }

    var body: some View
    {
        HStack(spacing: 12)
        {
            Button
            {
                onToggleCompletion()
            }
            label:
            {
                Image(systemName: event.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(
                        event.isCompleted ? ThemeManager.shared.buttonColor : .gray,
                    )
            }

            VStack(alignment: .leading, spacing: 2)
            {
                Text(event.title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .strikethrough(event.isCompleted)
                    .foregroundStyle(event.isCompleted ? .secondary : .primary)

                if let timeText
                {
                    Text(timeText)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Menu
            {
                Button
                {
                    onEdit()
                }
                label:
                {
                    Label("Edit", systemImage: "pencil")
                }

                Button(role: .destructive)
                {
                    onDelete()
                }
                label:
                {
                    Label("Delete", systemImage: "trash")
                }
            }
            label:
            {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
        }
        .padding(10)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
