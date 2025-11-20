import Combine
import FirebaseFirestore
import Foundation

extension DevbanTaskListView
{
    @Observable
    final class DevbanTaskListViewModel
    {
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
        private(set) var devbanTasks: [DevbanTask] = []
        let status: DevbanTask.Status
    }
}
