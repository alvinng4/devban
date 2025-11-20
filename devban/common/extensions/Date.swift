import Foundation

extension Date
{
    func formattedDeadline() -> String
    {
        let calendar: Calendar = Calendar(identifier: .gregorian)
        let date: Date = .init()

        // Check if yesterday
        if (calendar.isDateInYesterday(date))
        {
            return "Yesterday"
        }

        // Check if today
        if (calendar.isDateInToday(date))
        {
            return date.formatted(.dateTime.hour().minute())
        }

        // Check if tomorrow
        if (calendar.isDateInTomorrow(date))
        {
            return "Tmr " + date.formatted(.dateTime.hour().minute())
        }

        // Check if same year
        if calendar.isDate(date, equalTo: Date(), toGranularity: .year)
        {
            return date.formatted(.dateTime.day().month(.abbreviated))
        }

        // Default case (different year)
        return date.formatted(.dateTime.day().month(.abbreviated).year())
    }
}
