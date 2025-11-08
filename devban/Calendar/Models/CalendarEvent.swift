import Foundation

/// A structure representing a calendar event or deadline.
///
/// This structure encapsulates all information related to a calendar event, including its
/// title, date, optional time range, and completion status. It conforms to `Codable` for
/// persistence, `Equatable` for comparison, and `Identifiable` for SwiftUI list rendering.
struct CalendarEvent: Codable, Equatable, Identifiable
{
    /// Creates a new calendar event.
    ///
    /// - Parameters:
    ///   - id: Unique identifier for the event. Defaults to a new UUID if not provided.
    ///   - title: Title or description of the event.
    ///   - date: The date when the event occurs.
    ///   - startTime: Optional start time for the event. If provided, should be combined with
    ///     the date to form a complete timestamp.
    ///   - endTime: Optional end time for the event. Only meaningful if `startTime` is also
    ///     provided.
    ///   - isCompleted: Whether the event/deadline has been completed. Defaults to `false`.
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

    /// Unique identifier for the event.
    let id: UUID

    /// Title or description of the event.
    var title: String

    /// The date when the event occurs.
    let date: Date

    /// Optional start time for the event.
    var startTime: Date?

    /// Optional end time for the event.
    var endTime: Date?

    /// Whether the event/deadline has been completed.
    var isCompleted: Bool

    /// Returns `true` if the event occurs today.
    ///
    /// - Returns: `true` if the event's date is today; otherwise, `false`.
    var isToday: Bool
    {
        Calendar.current.isDateInToday(date)
    }

    /// Returns `true` if the event is in the past.
    ///
    /// An event is considered in the past if its date is before today and not today itself.
    ///
    /// - Returns: `true` if the event's date is before today; otherwise, `false`.
    var isPast: Bool
    {
        date < Date() && !Calendar.current.isDateInToday(date)
    }

    /// Returns `true` if the event is in the future.
    ///
    /// An event is considered in the future if its date is after today and not today itself.
    ///
    /// - Returns: `true` if the event's date is after today; otherwise, `false`.
    var isFuture: Bool
    {
        date > Date() && !Calendar.current.isDateInToday(date)
    }
}
