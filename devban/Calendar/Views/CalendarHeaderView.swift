import SwiftUI

/// Header view for the calendar showing month/year and navigation controls.
///
/// This view displays the current month and year, along with buttons to navigate to the
/// previous month, next month, and return to today's date.
struct CalendarHeaderView: View
{
    /// The currently selected date used to display the month and year.
    let selectedDate: Date

    /// Action to perform when navigating to the previous month.
    let onPreviousMonth: () -> Void

    /// Action to perform when navigating to the next month.
    let onNextMonth: () -> Void

    /// Action to perform when returning to today's date.
    let onToday: () -> Void

    /// Returns a formatted string representing the month and year.
    ///
    /// Format: "MMMM yyyy" (e.g., "January 2024").
    ///
    /// - Returns: A formatted string with the month and year.
    private var monthYearText: String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }

    var body: some View
    {
        HStack
        {
            Button
            {
                onPreviousMonth()
            }
            label:
            {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }

            Spacer()

            VStack(spacing: 2)
            {
                Text(monthYearText)
                    .font(.system(size: 18, weight: .bold, design: .rounded))

                Button
                {
                    onToday()
                }
                label:
                {
                    Text("Today")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(ThemeManager.shared.buttonColor)
                        .clipShape(Capsule())
                }
            }

            Spacer()

            Button
            {
                onNextMonth()
            }
            label:
            {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .padding()
    }
}
