import Combine
import FirebaseFirestore
import FirebaseSharedSwift
import SwiftUI

/// Represents a task in the Kanban board system.
///
/// Tasks track work items with status, progress, difficulty, deadlines, and can be
/// pinned for visibility. Completing tasks awards experience points to users.
struct DevbanTask: Codable, Hashable
{
    /// The current status of a task in the workflow
    enum Status: String, Codable, CaseIterable, Identifiable
    {
        /// Task is planned but not started
        case todo
        /// Task is currently being worked on
        case inProgress
        /// Task has been completed
        case completed

        var description: String
        {
            switch self
            {
                case .todo:
                    return "To-do"
                case .inProgress:
                    return "In Progress"
                case .completed:
                    return "Completed"
            }
        }

        var id: String
        {
            return self.description
        }
    }

    /// The task's unique identifier
    var id: String
    /// The ID of the team this task belongs to
    var teamId: String
    /// The task's title
    var title: String
    /// Detailed description of the task
    var description: String
    /// Timestamp when the task was created
    var createdDate: Date
    /// Completion progress from 0.0 to 1.0
    var progress: Double
    /// Current status of the task
    var status: Status
    /// Difficulty level determining experience points
    var difficulty: Difficulty
    /// Whether the task is pinned to the top of the list
    var isPinned: Bool
    /// Whether the task has a deadline set
    var hasDeadline: Bool
    /// The task's deadline date
    var deadline: Date
}

extension DevbanTask
{
    /// Updates the task document in Firestore with the provided data.
    ///
    /// - Parameters:
    ///   - id: The task's unique identifier
    ///   - data: Dictionary of fields to update
    static func updateDatabaseData(id: String, data: [String: Any]) async throws
    {
        try await DevbanTask.getTaskDocument(id).updateData(data)
    }

    /// Loads all tasks for a team with a specific status, ordered by creation date.
    ///
    /// - Parameters:
    ///   - teamID: The team's unique identifier
    ///   - status: The task status to filter by
    /// - Returns: Array of matching tasks
    static func loadTasks(teamID: String, status: Status) async throws -> [DevbanTask]
    {
        return try await DevbanTask.getTaskCollection()
            .whereField("team_id", isEqualTo: teamID)
            .whereField("status", isEqualTo: status.rawValue)
            .order(by: "created_date")
            .getDocuments(as: DevbanTask.self)
    }

    /// Retrieves a devbanTask from Firestore.
    ///
    /// - Parameter id: The task's unique identifier
    /// - Returns: The DevbanTask object
    static func getDevbanTask(_ id: String) async throws -> DevbanTask
    {
        return try await DevbanTask.getTaskDocument(id).getDocument(
            as: DevbanTask.self,
            decoder: decoder,
        )
    }

    /// Marks the task as completed and awards experience points to the user.
    func complete()
    {
        let data: [String: Any] = [
            "status": Status.completed.rawValue,
        ]
        let id: String = self.id

        Task
        {
            do
            {
                try await DevbanTask.updateDatabaseData(id: id, data: data)
                DevbanUserContainer.shared.addExp(difficulty.getExp())
            }
            catch
            {
                print("DevbanTeam.complete: \(error.localizedDescription)")
            }
        }
    }

    /// Marks the task as in-progress and removes previously awarded experience points.
    func uncomplete()
    {
        let data: [String: Any] = [
            "status": Status.inProgress.rawValue,
        ]
        let id: String = self.id

        Task
        {
            do
            {
                try await DevbanTask.updateDatabaseData(id: id, data: data)
                DevbanUserContainer.shared.addExp(-difficulty.getExp())
            }
            catch
            {
                print("DevbanTeam.uncomplete: \(error.localizedDescription)")
            }
        }
    }
}

extension DevbanTask
{
    /// Returns the Firestore collection reference for tasks.
    static func getTaskCollection() -> CollectionReference
    {
        return Firestore.firestore().collection("tasks")
    }

    /// Returns the Firestore document reference for a specific task.
    ///
    /// - Parameter id: The task's unique identifier
    static func getTaskDocument(_ id: String) -> DocumentReference
    {
        return DevbanTask.getTaskCollection().document(id)
    }

    /// Firestore encoder configured to convert camelCase to snake_case.
    private static var encoder: Firestore.Encoder
    {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }

    /// Firestore decoder configured to convert snake_case to camelCase.
    private static var decoder: Firestore.Decoder
    {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    /// Creates a new task document in Firestore.
    ///
    /// - Parameter devbanTask: The task object to create
    static func createNewTask(_ devbanTask: DevbanTask) throws
    {
        let taskDoc = DevbanTask.getTaskCollection().document(devbanTask.id)
        try taskDoc.setData(
            from: devbanTask,
            merge: false,
            encoder: DevbanTask.encoder,
        )
    }

    /// Deletes a task document from Firestore.
    ///
    /// - Parameter id: The task's unique identifier
    static func deleteTask(id: String) async throws
    {
        try await DevbanTask.getTaskDocument(id).delete()
    }
}
