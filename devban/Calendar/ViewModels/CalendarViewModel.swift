import Foundation
import SwiftUI

/// ViewModel for Calendar.
@Observable
final class CalendarViewModel
{
    init()
    {
        selectedDate = Date()
        events = []
    }

    var selectedDate: Date
    var events: [CalendarEvent]

    /// Returns events for a specific date
    func events(for date: Date) -> [CalendarEvent]
    {
        let calendar = Calendar.current
        return events.filter
        { event in
            calendar.isDate(event.date, inSameDayAs: date)
        }
    }

    /// Returns events for the currently selected date
    var selectedDateEvents: [CalendarEvent]
    {
        events(for: selectedDate)
    }

    /// Adds a new event
    func addEvent(_ event: CalendarEvent)
    {
        events.append(event)
        events.sort { $0.date < $1.date }
    }

    /// Updates an existing event
    func updateEvent(_ event: CalendarEvent)
    {
        if let index = events.firstIndex(where: { $0.id == event.id })
        {
            events[index] = event
            events.sort { $0.date < $1.date }
        }
    }

    /// Deletes an event
    func deleteEvent(_ event: CalendarEvent)
    {
        events.removeAll { $0.id == event.id }
    }

    /// Toggles completion status of an event
    func toggleEventCompletion(_ event: CalendarEvent)
    {
        if let index = events.firstIndex(where: { $0.id == event.id })
        {
            var updatedEvent = events[index]
            updatedEvent.isCompleted.toggle()
            events[index] = updatedEvent
        }
    }

    /// Moves to the previous month
    func previousMonth()
    {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)
        {
            selectedDate = newDate
        }
    }

    /// Moves to the next month
    func nextMonth()
    {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)
        {
            selectedDate = newDate
        }
    }

    /// Returns to today
    func goToToday()
    {
        selectedDate = Date()
    }
}
