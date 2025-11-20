import SwiftUI

/// Displays a preview of a task in a list with completion checkbox and navigation.
struct DevbanTaskPreviewView: View
{
    init(
        devbanTask: DevbanTask,
        navAction: @escaping () -> Void,
    )
    {
        self.devbanTask = devbanTask
        self.navAction = navAction
    }

    @Environment(\.colorScheme) private var colorScheme

    private let devbanTask: DevbanTask
    private let navAction: () -> Void

    @FocusState private var isTextFocused: Bool

    var body: some View
    {
        let isCompleted: Bool = (devbanTask.status == .completed)
        HStack(alignment: .firstTextBaseline)
        {
            // MARK: Checkbox

            if (!isCompleted)
            {
                Button
                {
                    devbanTask.complete()

                    HapticManager.shared.playSuccessNotification()
                    SoundManager.shared.playSuccessSound()
                }
                label:
                {
                    // Text so that the List divider start from the button
                    Text(
                        Image(systemName: "square"),
                    )
                    .font(.system(size: 20))
                    .foregroundStyle(colorScheme == .dark ? Color.secondary : Color.black)
                }
                .buttonStyle(.plain)
            }
            else
            {
                Button
                {
                    devbanTask.uncomplete()

                    HapticManager.shared.playSuccessNotification()
                }
                label:
                {
                    Text(
                        Image(systemName: "checkmark.square"),
                    )
                    .font(.system(size: 20))
                    .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
            }

            Button(action: navAction)
            {
                VStack(spacing: 0)
                {
                    HStack
                    {
                        if (!isCompleted)
                        {
                            Text(devbanTask.title)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        else
                        {
                            Text(devbanTask.title)
                                .strikethrough()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        HStack
                        {
                            if (devbanTask.isPinned)
                            {
                                Image(systemName: "pin.fill")
                                    .rotationEffect(.degrees(45))
                                    .font(.footnote)
                                    .frame(alignment: .topTrailing)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .font(.footnote)
                        .frame(maxHeight: .infinity, alignment: .topTrailing)
                        .padding(.top, 4)
                        .foregroundStyle(.secondary)
                    }

                    if (!devbanTask.description.isEmptyOrWhitespace())
                    {
                        Text(devbanTask.description)
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if (devbanTask.hasDeadline)
                    {
                        let displayString: String = "Deadline: \(devbanTask.deadline.formattedDeadline())"
                        let isPast: Bool = devbanTask.deadline < Date()
                        Text(displayString)
                            .font(.footnote)
                            .lineLimit(1)
                            .foregroundStyle(
                                (!isCompleted && isPast) ?
                                    Color.red : (colorScheme == .dark ? Color.white : Color.black),
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    HStack
                    {
                        ProgressView(value: devbanTask.progress, total: 100.0)
                            .tint(devbanTask.difficulty.getColor())
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("\(Int(devbanTask.progress))%")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .dropDestination(for: String.self)
        { items, _ in
            for dropString in items
            {
                let splitString: [String] = dropString.components(separatedBy: .whitespaces)
                guard !splitString.isEmpty else { continue }

                if (splitString.count >= 2 && splitString[0] == "Task")
                {
                    Task
                    {
                        do
                        {
                            try await DevbanTask.updateDatabaseData(
                                id: splitString[1],
                                data: ["status": devbanTask.status.rawValue],
                            )
                        }
                        catch
                        {
                            print(error.localizedDescription)
                        }
                    }
                }
            }

            return true
        }
        .padding(.leading, 10)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .leading)
        {
            Rectangle()
                .frame(width: 6)
                .foregroundStyle(devbanTask.difficulty.getColor())
        }
    }
}
