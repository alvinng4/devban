import Foundation

/// A structure representing a calendar event or deadline.
///
/// - Parameters:
///     - id: Unique identifier for the event.
///     - title: Title or description of the event.
///     - date: The date when the event occurs.
///     - startTime: Optional start time for the event.
///     - endTime: Optional end time for the event.
///     - isCompleted: Whether the event/deadline has been completed.
struct CalendarEvent: Codable, Equatable, Identifiable
{
    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        startTime: Date? = nil,
        endTime: Date? = nil,
        isCompleted: Bool = false,
    )
    {
        self.id = id
        self.title = title
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.isCompleted = isCompleted
    }

    let id: UUID
    var title: String
    let date: Date
    var startTime: Date?
    var endTime: Date?
    var isCompleted: Bool

    /// Returns true if the event is today
    var isToday: Bool
    {
        Calendar.current.isDateInToday(date)
    }

    /// Returns true if the event is in the past
    var isPast: Bool
    {
        date < Date() && !Calendar.current.isDateInToday(date)
    }

    /// Returns true if the event is in the future
    var isFuture: Bool
    {
        date > Date() && !Calendar.current.isDateInToday(date)
    }
}
