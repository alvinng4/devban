import SwiftUI

/// Individual day cell in the calendar grid.
struct CalendarDayCell: View
{
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let eventsCount: Int
    let onTap: () -> Void

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

                if eventsCount > 0
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
        .buttonStyle(PlainButtonStyle())
    }
}
