import FirebaseFirestore
import FirebaseSharedSwift
import SwiftUI

struct DevbanTask: Codable, Hashable
{
    enum Status: String, Codable
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

    static func deleteTask(id: String) async throws
    {
        try await DevbanTask.getTaskDocument(id).delete()
    }

    static func loadTasks(teamID: String, status: Status) async throws -> [DevbanTask]
    {
        try await DevbanTask.getTaskCollection()
            .whereField("team_id", isEqualTo: teamID)
            .whereField("status", isEqualTo: status)
            .order(by: "created_date")
            .getDocuments(as: DevbanTask.self)
    }

    func setProgress(_ progress: Double)
    {
        let data: [String: Any] = [
            "progress": progress,
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
                print("DevbanTeam.setProgress: \(error.localizedDescription)")
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

    func createNewTask(_ devbanTask: DevbanTask) async throws
    {
        let taskDoc = DevbanTeam.getTeamCollection().document(devbanTask.id)
        try taskDoc.setData(
            from: devbanTask,
            merge: false,
            encoder: DevbanTask.encoder,
        )
    }
}
