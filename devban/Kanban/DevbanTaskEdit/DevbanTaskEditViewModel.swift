import SwiftUI

/// View model for creating and editing tasks.
///
/// This view model manages task properties and synchronizes changes with Firestore.
/// It supports both creating new tasks and editing existing ones.
@Observable
final class DevbanTaskEditViewModel
{
    /// Initializes a new task with the specified status.
    ///
    /// - Parameter status: The initial status for the task
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

    /// Initializes a new task with a specific deadline.
    ///
    /// - Parameters:
    ///   - status: The initial status for the task
    ///   - deadline: The deadline date for the task
    init(status: DevbanTask.Status, deadline: Date)
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
            hasDeadline: true,
            deadline: deadline,
        )

        self.devbanTask = newTask
        self.isNewTask = true
        self.difficultyValue = newTask.difficulty.getDifficultyValue()
    }

    /// Initializes for editing an existing task.
    ///
    /// - Parameter devbanTask: The existing task to edit
    init(devbanTask: DevbanTask)
    {
        self.devbanTask = devbanTask
        self.isNewTask = false
        self.difficultyValue = devbanTask.difficulty.getDifficultyValue()
    }

    /// The task being created or edited
    var devbanTask: DevbanTask
    /// Whether this is a new task (true) or editing existing (false)
    var isNewTask: Bool
    /// Numeric value for the difficulty slider UI
    var difficultyValue: Double

    /// Updates the task difficulty based on the slider value.
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

    /// Updates the pinned status in Firestore.
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

    /// Updates the task title in Firestore.
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

    /// Updates the task description in Firestore.
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

    /// Updates the task status in Firestore.
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

    /// Updates the task difficulty in Firestore.
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

    /// Updates whether the task has a deadline in Firestore.
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

    /// Updates the task deadline in Firestore.
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

    /// Updates the task progress in Firestore.
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

    /// Creates a new task in Firestore and provides haptic feedback.
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

    /// Deletes the task from Firestore and provides haptic feedback.
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
