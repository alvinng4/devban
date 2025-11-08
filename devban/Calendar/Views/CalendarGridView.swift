import SwiftUI

/// Grid view displaying the calendar days.
///
/// This view renders a calendar grid showing all days in the month, with weekday headers
/// and individual day cells. It handles the layout of days, including empty cells for
/// days before the first day of the month.
struct CalendarGridView: View
{
    /// Binding to the currently selected date.
    @Binding var selectedDate: Date

    /// All calendar events to display event indicators on days.
    let events: [CalendarEvent]

    /// The calendar instance used for date calculations.
    private let calendar = Calendar.current

    /// Abbreviated weekday names for the header.
    private let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    /// Extracts the month and year from the selected date.
    ///
    /// - Returns: A tuple containing the month (1-12) and year.
    private var monthYear: (month: Int, year: Int)
    {
        let components = calendar.dateComponents([.month, .year], from: selectedDate)
        return (month: components.month ?? 1, year: components.year ?? 2024)
    }

    /// Returns the first day of the month for the selected date.
    ///
    /// - Returns: A `Date` representing the first day of the month.
    private var firstDayOfMonth: Date
    {
        calendar.date(from: DateComponents(year: monthYear.year, month: monthYear.month, day: 1)) ?? Date()
    }

    /// Returns the weekday index (0-6) of the first day of the month.
    ///
    /// Sunday is 0, Monday is 1, and so on.
    ///
    /// - Returns: The weekday index of the first day of the month.
    private var firstWeekday: Int
    {
        calendar.component(.weekday, from: firstDayOfMonth) - 1
    }

    /// Returns the number of days in the month for the selected date.
    ///
    /// - Returns: The number of days in the month (28-31).
    private var daysInMonth: Int
    {
        calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
    }

    /// Returns an array of dates for the calendar grid.
    ///
    /// The array includes `nil` values for empty cells before the first day of the month,
    /// followed by all dates in the month.
    ///
    /// - Returns: An array of optional `Date` values representing the calendar grid.
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

    /// Returns the number of events on a specific date.
    ///
    /// - Parameter date: The date for which to count events.
    /// - Returns: The number of events occurring on the specified date.
    private func eventsCount(for date: Date) -> Int
    {
        events.count(where: { calendar.isDate($0.date, inSameDayAs: date) })
    }

    /// Returns `true` if the given date is the currently selected date.
    ///
    /// - Parameter date: The date to check.
    /// - Returns: `true` if the date matches the selected date; otherwise, `false`.
    private func isDateSelected(_ date: Date) -> Bool
    {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }

    /// Returns `true` if the given date is today.
    ///
    /// - Parameter date: The date to check.
    /// - Returns: `true` if the date is today; otherwise, `false`.
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
