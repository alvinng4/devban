import SwiftUI

/// View showing events for the selected date.
struct SelectedDateEventsView: View
{
    let date: Date
    let events: [CalendarEvent]
    let onToggleCompletion: (CalendarEvent) -> Void
    let onDelete: (CalendarEvent) -> Void
    let onEdit: (CalendarEvent) -> Void

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
struct EventRowView: View
{
    let event: CalendarEvent
    let onToggleCompletion: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void

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
