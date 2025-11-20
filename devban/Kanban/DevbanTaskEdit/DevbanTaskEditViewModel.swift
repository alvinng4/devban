import SwiftUI

@Observable
final class DevbanTaskEditViewModel
{
    init(status: DevbanTask.Status)
    {
        let newTask: DevbanTask = .init(
            id: UUID().uuidString,
            teamId: DevbanUserContainer.shared.getTeamId() ?? "Error",
            title: "",
            description: "",
            createdDate: Date(),
            progress: 0,
            status: status,
            difficulty: .easy,
            isPinned: false,
            hasDeadline: false,
            deadline: Date().addingTimeInterval(86400 * 7),
        )

        self.devbanTask = newTask
        self.difficultyValue = newTask.difficulty.getDifficultyValue()
        self.deadline = newTask.deadline
    }

    init(devbanTask: DevbanTask)
    {
        self.devbanTask = devbanTask
        self.difficultyValue = devbanTask.difficulty.getDifficultyValue()
        self.deadline = devbanTask.deadline
    }

    var devbanTask: DevbanTask
    var difficultyValue: Double
    var deadline: Date

    func updateDifficulty()
    {
        switch (Int(difficultyValue.rounded()))
        {
            case 0:
                devbanTask.difficulty = .veryEasy
            case 1:
                devbanTask.difficulty = .easy
            case 2:
                devbanTask.difficulty = .normal
            case 3:
                devbanTask.difficulty = .hard
            case 4:
                devbanTask.difficulty = .veryHard
            default:
                devbanTask.difficulty = .easy
        }
    }

    func updateDeadline()
    {
        devbanTask.deadline = deadline
    }

    func togglePin()
    {
        // TODO: togglePIN
    }

    @MainActor
    func saveTask()
    {
        // TODO: saveTask

        HapticManager.shared.playSuccessNotification()
    }

    func deleteTask()
    {
        // TODO: deleteTask
    }
}
