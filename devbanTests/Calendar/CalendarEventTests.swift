@testable import devban
import Foundation
import Testing

/// Unit tests for the `CalendarEvent` model.
struct CalendarEventTests
{
    // MARK: - Init / stored properties

    /// Stores all provided values exactly as given.
    @Test
    func init_usesProvidedValues() throws
    {
        let customId = UUID()
        let date = Date()
        let startTime = date
        let endTime = Calendar.current.date(byAdding: .hour, value: 1, to: date)!
        let title = "Custom event"
        let isCompleted = true

        let event = CalendarEvent(
            id: customId,
            title: title,
            date: date,
            startTime: startTime,
            endTime: endTime,
            isCompleted: isCompleted,
        )

        #expect(event.id == customId)
        #expect(event.title == title)
        #expect(event.date == date)
        #expect(event.startTime == startTime)
        #expect(event.endTime == endTime)
        #expect(event.isCompleted == isCompleted)
    }

    /// Uses documented default values when optional parameters are omitted.
    @Test
    func init_usesDefaultValuesWhenOmitted() throws
    {
        let date = Date()

        let event = CalendarEvent(
            title: "Default event",
            date: date,
        )

        #expect(event.title == "Default event")
        #expect(event.date == date)
        #expect(event.startTime == nil)
        #expect(event.endTime == nil)
        #expect(event.isCompleted == false)
    }

    // MARK: - Date flags

    /// Event dated today is flagged as today only.
    @Test
    func isToday_isTrueOnlyForToday() throws
    {
        let today = Date()

        let event = CalendarEvent(
            title: "Today event",
            date: today,
        )

        #expect(event.isToday == true)
        #expect(event.isPast == false)
        #expect(event.isFuture == false)
    }

    /// Event dated yesterday is flagged as past only.
    @Test
    func isPast_isTrueForYesterday() throws
    {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let event = CalendarEvent(
            title: "Yesterday event",
            date: yesterday,
        )

        #expect(event.isToday == false)
        #expect(event.isPast == true)
        #expect(event.isFuture == false)
    }

    /// Event dated tomorrow is flagged as future only.
    @Test
    func isFuture_isTrueForTomorrow() throws
    {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        let event = CalendarEvent(
            title: "Tomorrow event",
            date: tomorrow,
        )

        #expect(event.isToday == false)
        #expect(event.isPast == false)
        #expect(event.isFuture == true)
    }

    /// Far past dates are still treated as past.
    @Test
    func isPast_isTrueForFarPastDate() throws
    {
        let calendar = Calendar.current
        let today = Date()
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today)!

        let event = CalendarEvent(
            title: "Old event",
            date: thirtyDaysAgo,
        )

        #expect(event.isToday == false)
        #expect(event.isPast == true)
        #expect(event.isFuture == false)
    }

    /// Far future dates are still treated as future.
    @Test
    func isFuture_isTrueForFarFutureDate() throws
    {
        let calendar = Calendar.current
        let today = Date()
        let thirtyDaysFromNow = calendar.date(byAdding: .day, value: 30, to: today)!

        let event = CalendarEvent(
            title: "Future event",
            date: thirtyDaysFromNow,
        )

        #expect(event.isToday == false)
        #expect(event.isPast == false)
        #expect(event.isFuture == true)
    }

    /// Completion status does not change date flags.
    @Test
    func isCompleted_doesNotAffectDateFlags() throws
    {
        let today = Date()

        let event = CalendarEvent(
            title: "Completed today",
            date: today,
            isCompleted: true,
        )

        #expect(event.isToday == true)
        #expect(event.isPast == false)
        #expect(event.isFuture == false)
    }
}
