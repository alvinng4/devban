import SwiftUI

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
