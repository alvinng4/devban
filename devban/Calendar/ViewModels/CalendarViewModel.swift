import Combine
import FirebaseFirestore
import Foundation
import SwiftUI

/// ViewModel for managing calendar state and operations.
///
/// This class manages the calendar's state, including the selected date and tasks with deadlines.
/// It provides methods for querying tasks and navigating between months. The class is marked
/// as `@Observable` to enable SwiftUI automatic observation and view updates.
@Observable
final class CalendarViewModel
{
    /// Creates a new calendar view model.
    ///
    /// Initializes the view model with the current date as the selected date and sets up
    /// a Firebase listener for tasks with deadlines.
    init()
    {
        selectedDate = Date()
        tasks = []
        
        guard let teamId: String = DevbanUserContainer.shared.getTeamId()
        else
        {
            return
        }

        let (publisher, listener) = DevbanTask.getTaskCollection()
            .whereField("team_id", isEqualTo: teamId)
            .whereField("has_deadline", isEqualTo: true)
            .order(by: "deadline")
            .addSnapshotListener(as: DevbanTask.self)

        self.tasksListener = listener
        publisher
            .receive(on: DispatchQueue.main)
            .sink
            { completion in
                if case let .failure(error) = completion
                {
                    print("Listener error: \(error)")
                }
            }
            receiveValue:
            { [weak self] tasks in
                self?.tasks = tasks
            }
            .store(in: &cancellables)
    }

    deinit
    {
        tasksListener?.remove()
    }

    /// The currently selected date in the calendar.
    var selectedDate: Date

    /// All tasks with deadlines managed by this view model.
    private(set) var tasks: [DevbanTask]

    private var cancellables: Set<AnyCancellable> = .init()
    private var tasksListener: ListenerRegistration?

    /// Returns all tasks that have a deadline on a specific date.
    ///
    /// - Parameter date: The date for which to retrieve tasks.
    /// - Returns: An array of `DevbanTask` objects that have a deadline on the specified date.
    func tasks(for date: Date) -> [DevbanTask]
    {
        let calendar = Calendar.current
        return tasks.filter
        { task in
            task.hasDeadline && calendar.isDate(task.deadline, inSameDayAs: date)
        }
    }

    /// Returns all tasks for the currently selected date.
    ///
    /// - Returns: An array of `DevbanTask` objects for the selected date.
    var selectedDateTasks: [DevbanTask]
    {
        tasks(for: selectedDate)
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
