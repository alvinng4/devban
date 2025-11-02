import SwiftUI

/// Grid view displaying the calendar days.
struct CalendarGridView: View
{
    @Binding var selectedDate: Date
    let events: [CalendarEvent]

    private let calendar = Calendar.current
    private let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    private var monthYear: (month: Int, year: Int)
    {
        let components = calendar.dateComponents([.month, .year], from: selectedDate)
        return (month: components.month ?? 1, year: components.year ?? 2024)
    }

    private var firstDayOfMonth: Date
    {
        calendar.date(from: DateComponents(year: monthYear.year, month: monthYear.month, day: 1)) ?? Date()
    }

    private var firstWeekday: Int
    {
        calendar.component(.weekday, from: firstDayOfMonth) - 1
    }

    private var daysInMonth: Int
    {
        calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
    }

    private var calendarDays: [Date?]
    {
        var days: [Date?] = []

        // Add empty cells for days before the first day of the month
        for _ in 0 ..< firstWeekday
        {
            days.append(nil)
        }

        // Add all days of the month
        for day in 1 ... daysInMonth
        {
            if let date = calendar.date(from: DateComponents(year: monthYear.year, month: monthYear.month, day: day))
            {
                days.append(date)
            }
        }

        return days
    }

    private func eventsCount(for date: Date) -> Int
    {
        events.count(where: { calendar.isDate($0.date, inSameDayAs: date) })
    }

    private func isDateSelected(_ date: Date) -> Bool
    {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }

    private func isDateToday(_ date: Date) -> Bool
    {
        calendar.isDateInToday(date)
    }

    var body: some View
    {
        VStack(spacing: 8)
        {
            // Week day headers
            HStack(spacing: 0)
            {
                ForEach(weekDays, id: \.self)
                { day in
                    Text(day)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4)
            {
                ForEach(Array(calendarDays.enumerated()), id: \.offset)
                { _, date in
                    if let date
                    {
                        CalendarDayCell(
                            date: date,
                            isSelected: isDateSelected(date),
                            isToday: isDateToday(date),
                            eventsCount: eventsCount(for: date),
                            onTap: { selectedDate = date },
                        )
                    }
                    else
                    {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
    }
}
