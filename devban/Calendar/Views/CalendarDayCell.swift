import SwiftUI

/// Individual day cell in the calendar grid.
///
/// This view displays a single day in the calendar grid, showing the day number and an
/// indicator if there are tasks with deadlines on that day. The cell can be selected and highlights
/// today's date differently.
struct CalendarDayCell: View
{
    /// The date represented by this cell.
    let date: Date

    /// Whether this cell is currently selected.
    let isSelected: Bool

    /// Whether this cell represents today's date.
    let isToday: Bool

    /// The number of tasks with deadlines on this date.
    let tasksCount: Int

    /// The action to perform when the cell is tapped.
    let onTap: () -> Void

    /// The day number extracted from the date.
    ///
    /// - Returns: The day of the month (1-31).
    private var dayNumber: Int
    {
        Calendar.current.component(.day, from: date)
    }

    var body: some View
    {
        Button(action: onTap)
        {
            VStack(spacing: 2)
            {
                Text("\(dayNumber)")
                    .font(.system(size: 14, weight: isSelected ? .bold : .regular, design: .rounded))
                    .foregroundStyle(
                        isSelected ? .white :
                            isToday ? ThemeManager.shared.buttonColor :
                            .primary,
                    )

                if tasksCount > 0
                {
                    Circle()
                        .fill(
                            isSelected ? .white :
                                ThemeManager.shared.buttonColor,
                        )
                        .frame(width: 4, height: 4)
                }
                else
                {
                    Spacer()
                        .frame(height: 4)
                }
            }
            .frame(width: 40, height: 50)
            .background(
                isSelected ?
                    ThemeManager.shared.buttonColor :
                    (isToday ? ThemeManager.shared.buttonColor.opacity(0.2) : Color.clear),
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(
                        isSelected ? Color.black : Color.clear,
                        lineWidth: isSelected ? 2 : 0,
                    ),
            )
        }
    }
}
