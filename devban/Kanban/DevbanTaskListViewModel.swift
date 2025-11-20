import Combine
import FirebaseFirestore
import Foundation

extension DevbanTaskListView
{
    /// View model for managing a list of tasks with a specific status.
    ///
    /// This view model maintains a real-time listener for tasks belonging to the current
    /// team and filters them by status. Tasks are ordered by pinned status and creation date.
    @Observable
    final class DevbanTaskListViewModel
    {
        /// Initializes the view model and sets up a Firestore listener for tasks.
        ///
        /// - Parameter status: The task status to filter by
        init(status: DevbanTask.Status)
        {
            self.status = status

            guard let teamId: String = DevbanUserContainer.shared.getTeamId()
            else
            {
                return
            }

            let (publisher, listener) = DevbanTask.getTaskCollection()
                .whereField("team_id", isEqualTo: teamId)
                .whereField("status", isEqualTo: status.rawValue)
                .order(by: "is_pinned", descending: true)
                .order(by: "created_date", descending: true)
                .addSnapshotListener(as: DevbanTask.self)

            self.devbanTasksListener = listener
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
                { [weak self] devbanTasks in
                    self?.devbanTasks = devbanTasks
                }
                .store(in: &cancellables)
        }

        deinit
        {
            devbanTasksListener?.remove()
        }

        private var cancellables: Set<AnyCancellable> = .init()
        private var devbanTasksListener: ListenerRegistration?
        /// The list of tasks for the current status
        private(set) var devbanTasks: [DevbanTask] = []
        /// The status filter for this list
        let status: DevbanTask.Status
    }
}
