import Combine
import FirebaseFirestore
import FirebaseSharedSwift
import SwiftUI

struct DevbanTask: Codable, Hashable
{
    enum Status: String, Codable, CaseIterable, Identifiable
    {
        case todo
        case inProgress
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

    var id: String
    var teamId: String
    var title: String
    var description: String
    var createdDate: Date
    var progress: Double
    var status: Status
    var difficulty: Difficulty
    var isPinned: Bool
    var hasDeadline: Bool
    var deadline: Date
}

extension DevbanTask
{
    static func updateDatabaseData(id: String, data: [String: Any]) async throws
    {
        try await DevbanTask.getTaskDocument(id).updateData(data)
    }

    static func loadTasks(teamID: String, status: Status) async throws -> [DevbanTask]
    {
        return try await DevbanTask.getTaskCollection()
            .whereField("team_id", isEqualTo: teamID)
            .whereField("status", isEqualTo: status.rawValue)
            .order(by: "created_date")
            .getDocuments(as: DevbanTask.self)
    }

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
            }
            catch
            {
                print("DevbanTeam.complete: \(error.localizedDescription)")
            }
        }
    }

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
    static func getTaskCollection() -> CollectionReference
    {
        return Firestore.firestore().collection("tasks")
    }

    static func getTaskDocument(_ id: String) -> DocumentReference
    {
        return DevbanTask.getTaskCollection().document(id)
    }

    private static var encoder: Firestore.Encoder
    {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }

    private static var decoder: Firestore.Decoder
    {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    static func createNewTask(_ devbanTask: DevbanTask) throws
    {
        let taskDoc = DevbanTask.getTaskCollection().document(devbanTask.id)
        try taskDoc.setData(
            from: devbanTask,
            merge: false,
            encoder: DevbanTask.encoder,
        )
    }

    static func deleteTask(id: String) async throws
    {
        try await DevbanTask.getTaskDocument(id).delete()
    }
}
