import Foundation

extension Date
{
    func formattedDeadline() -> String
    {
        let calendar: Calendar = Calendar(identifier: .gregorian)

        // Check if yesterday
        if (calendar.isDateInYesterday(self))
        {
            return "Yesterday"
        }

        // Check if today
        if (calendar.isDateInToday(self))
        {
            return self.formatted(.dateTime.hour().minute())
        }

        // Check if tomorrow
        if (calendar.isDateInTomorrow(self))
        {
            return "Tmr " + self.formatted(.dateTime.hour().minute())
        }

        // Check if same year
        if calendar.isDate(self, equalTo: Date(), toGranularity: .year)
        {
            return self.formatted(.dateTime.day().month(.abbreviated))
        }

        // Default case (different year)
        return self.formatted(.dateTime.day().month(.abbreviated).year())
    }
}
