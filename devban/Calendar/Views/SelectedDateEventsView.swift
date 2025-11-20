import SwiftUI

/// View showing tasks with deadlines for the selected date.
///
/// This view displays a list of all tasks with deadlines occurring on a specific date.
/// If no tasks exist, it shows an empty state message.
struct SelectedDateEventsView: View
{
    /// The date for which to display tasks.
    let date: Date

    /// The tasks to display for the selected date.
    let tasks: [DevbanTask]

    /// Navigation path for navigating to task details.
    @Binding var navPath: NavigationPath

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

            if tasks.isEmpty
            {
                VStack(spacing: 8)
                {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)

                    Text("No deadlines scheduled")
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
                        ForEach(tasks, id: \.id)
                        { task in
                            DevbanTaskPreviewView(
                                devbanTask: task,
                            )
                            {
                                navPath.append(task)
                            }
                            .padding(.trailing)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .tint(.primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
            }
        }
    }
}
