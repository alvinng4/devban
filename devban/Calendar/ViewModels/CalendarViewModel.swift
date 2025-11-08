import Foundation
import SwiftUI

/// ViewModel for managing calendar state and operations.
///
/// This class manages the calendar's state, including the selected date and all calendar events.
/// It provides methods for querying, adding, updating, and deleting events, as well as
/// navigating between months. The class is marked as `@Observable` to enable SwiftUI
/// automatic observation and view updates.
@Observable
final class CalendarViewModel
{
    /// Creates a new calendar view model.
    ///
    /// Initializes the view model with the current date as the selected date and an empty
    /// events array.
    init()
    {
        selectedDate = Date()
        events = []
    }

    /// The currently selected date in the calendar.
    var selectedDate: Date

    /// All calendar events managed by this view model.
    ///
    /// Events are automatically sorted by date whenever they are added or updated.
    var events: [CalendarEvent]

    /// Returns all events that occur on a specific date.
    ///
    /// - Parameter date: The date for which to retrieve events.
    /// - Returns: An array of `CalendarEvent` objects that occur on the specified date.
    func events(for date: Date) -> [CalendarEvent]
    {
        let calendar = Calendar.current
        return events.filter
        { event in
            calendar.isDate(event.date, inSameDayAs: date)
        }
    }

    /// Returns all events for the currently selected date.
    ///
    /// - Returns: An array of `CalendarEvent` objects for the selected date.
    var selectedDateEvents: [CalendarEvent]
    {
        events(for: selectedDate)
    }

    /// Adds a new event to the calendar.
    ///
    /// The event is appended to the events array and the array is automatically sorted
    /// by date in ascending order.
    ///
    /// - Parameter event: The event to add to the calendar.
    func addEvent(_ event: CalendarEvent)
    {
        events.append(event)
        events.sort { $0.date < $1.date }
    }

    /// Updates an existing event in the calendar.
    ///
    /// If an event with the same ID exists, it is replaced with the provided event and
    /// the events array is re-sorted by date.
    ///
    /// - Parameter event: The event to update. Must have an ID matching an existing event.
    func updateEvent(_ event: CalendarEvent)
    {
        if let index = events.firstIndex(where: { $0.id == event.id })
        {
            events[index] = event
            events.sort { $0.date < $1.date }
        }
    }

    /// Deletes an event from the calendar.
    ///
    /// - Parameter event: The event to delete. Must have an ID matching an existing event.
    func deleteEvent(_ event: CalendarEvent)
    {
        events.removeAll { $0.id == event.id }
    }

    /// Toggles the completion status of an event.
    ///
    /// If the event is found, its `isCompleted` property is toggled between `true` and `false`.
    ///
    /// - Parameter event: The event whose completion status should be toggled.
    func toggleEventCompletion(_ event: CalendarEvent)
    {
        if let index = events.firstIndex(where: { $0.id == event.id })
        {
            var updatedEvent = events[index]
            updatedEvent.isCompleted.toggle()
            events[index] = updatedEvent
        }
    }

    /// Moves the selected date to the previous month.
    ///
    /// Updates `selectedDate` to the same day of the previous month. If the current month
    /// has more days than the previous month, the date is adjusted to the last day of
    /// the previous month.
    func previousMonth()
    {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)
        {
            selectedDate = newDate
        }
    }

    /// Moves the selected date to the next month.
    ///
    /// Updates `selectedDate` to the same day of the next month. If the current month
    /// has more days than the next month, the date is adjusted to the last day of
    /// the next month.
    func nextMonth()
    {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)
        {
            selectedDate = newDate
        }
    }

    /// Sets the selected date to today.
    ///
    /// Updates `selectedDate` to the current date.
    func goToToday()
    {
        selectedDate = Date()
    }
}
