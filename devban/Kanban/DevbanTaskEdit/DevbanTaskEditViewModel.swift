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
        self.isNewTask = true
        self.difficultyValue = newTask.difficulty.getDifficultyValue()
    }

    init(devbanTask: DevbanTask)
    {
        self.devbanTask = devbanTask
        self.isNewTask = false
        self.difficultyValue = devbanTask.difficulty.getDifficultyValue()
    }

    var devbanTask: DevbanTask
    var isNewTask: Bool
    var difficultyValue: Double

    func updateDifficultyUI()
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

    func updateIsPinned()
    {
        guard !isNewTask else { return }
        Task
        {
            do
            {
                try await DevbanTask.updateDatabaseData(
                    id: devbanTask.id,
                    data: ["is_pinned": devbanTask.isPinned],
                )
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }

    func updateTitle()
    {
        guard !isNewTask else { return }
        Task
        {
            do
            {
                try await DevbanTask.updateDatabaseData(
                    id: devbanTask.id,
                    data: ["title": devbanTask.title],
                )
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }

    func updateDescription()
    {
        guard !isNewTask else { return }
        Task
        {
            do
            {
                try await DevbanTask.updateDatabaseData(
                    id: devbanTask.id,
                    data: ["description": devbanTask.description],
                )
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }

    func updateStatus()
    {
        guard !isNewTask else { return }
        Task
        {
            do
            {
                try await DevbanTask.updateDatabaseData(
                    id: devbanTask.id,
                    data: ["status": devbanTask.status.rawValue],
                )
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }

    func updateDifficulty()
    {
        guard !isNewTask else { return }
        Task
        {
            do
            {
                try await DevbanTask.updateDatabaseData(
                    id: devbanTask.id,
                    data: ["difficulty": devbanTask.difficulty.rawValue],
                )
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }

    func updateHasDeadline()
    {
        guard !isNewTask else { return }
        Task
        {
            do
            {
                try await DevbanTask.updateDatabaseData(
                    id: devbanTask.id,
                    data: ["has_deadline": devbanTask.hasDeadline],
                )
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }

    func updateDeadline()
    {
        guard !isNewTask else { return }
        Task
        {
            do
            {
                try await DevbanTask.updateDatabaseData(
                    id: devbanTask.id,
                    data: ["deadline": devbanTask.deadline],
                )
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }

    func updateProgress()
    {
        guard !isNewTask else { return }
        Task
        {
            do
            {
                try await DevbanTask.updateDatabaseData(
                    id: devbanTask.id,
                    data: ["progress": devbanTask.progress],
                )
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }

    func saveTask()
    {
        do
        {
            try DevbanTask.createNewTask(devbanTask)
            HapticManager.shared.playSuccessNotification()
        }
        catch
        {
            print("Save task error: \(error.localizedDescription)")
        }
    }

    func deleteTask()
    {
        Task
        {
            do
            {
                try await DevbanTask.deleteTask(id: devbanTask.id)
                HapticManager.shared.playSuccessNotification()
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    }
}
