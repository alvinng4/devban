import Foundation

extension Date
{
    /// Formats a date as a human-readable deadline string.
    ///
    /// Returns different formats based on the date:
    /// - Yesterday: "Yesterday"
    /// - Today: Time only (e.g., "2:30 PM")
    /// - Tomorrow: "Tmr" + time (e.g., "Tmr 2:30 PM")
    /// - This year: Day and month (e.g., "Jan 15")
    /// - Other years: Day, month, and year (e.g., "Jan 15, 2023")
    ///
    /// - Returns: A formatted string representing the deadline
    func formattedDeadline() -> String
    {
        let calendar: Calendar = Calendar(identifier: .gregorian)

        if (calendar.isDateInYesterday(self))
        {
            return "Yesterday"
        }

        if (calendar.isDateInToday(self))
        {
            return self.formatted(.dateTime.hour().minute())
        }

        if (calendar.isDateInTomorrow(self))
        {
            return "Tmr " + self.formatted(.dateTime.hour().minute())
        }

        if calendar.isDate(self, equalTo: Date(), toGranularity: .year)
        {
            return self.formatted(.dateTime.day().month(.abbreviated))
        }

        return self.formatted(.dateTime.day().month(.abbreviated).year())
    }
}
