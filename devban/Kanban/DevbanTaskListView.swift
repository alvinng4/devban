import SwiftUI

struct DevbanTaskListView: View
{
    init(devbanTasks: [DevbanTask], status: DevbanTask.Status, navPath: Binding<NavigationPath>)
    {
        self.devbanTasks = devbanTasks
        self.status = status
        _navPath = navPath
    }

    private let devbanTasks: [DevbanTask]
    private let status: DevbanTask.Status
    @Binding private var navPath: NavigationPath

    var body: some View
    {
        ZStack
        {
            GeometryReader
            { _ in
                List
                {
                    ForEach(devbanTasks, id: \.self)
                    { devbanTask in
                        DevbanTaskPreviewView(
                            devbanTask: devbanTask,
                        )
                        {
                            navPath.append(devbanTask)
                        }
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 12))
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true)
                        {
                            Button("Delete")
                            {
                                // TODO: Implement this
                            }
                            .tint(.red)
                        }
                        // TODO: Implement customDraggable
//                        .customDraggable(
//                            isDraggable: isDraggable,
//                            transferString: "Quest \(quest.id.uuidString)",
//                        )
                    }

                    // TODO: Implement dragging
//                    if (isDraggable)
//                    {
//                        Color.clear
//                            .frame(height: max(0.0, proxy.size.height - 100.0 - CGFloat(sortedQuestsID.count) * 50.0))
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                            .dropDestination(for: String.self)
//                            { items, _ in
//                                for dropString in items
//                                {
//                                    let splitString: [String] = dropString.components(separatedBy: .whitespaces)
//                                    guard !splitString.isEmpty else { continue }
//
//                                    if (splitString.count >= 2 && splitString[0] == "Quest")
//                                    {
//                                        if let questUUID: UUID = UUID(uuidString: splitString[1]),
//                                           let quest: Quest = (quests.first { $0.id == questUUID })
//                                        {
//                                            if (isAnytime)
//                                            {
//                                                quest.assignedDateType = .anytime
//                                            }
//                                            else
//                                            {
//                                                quest.assignedDateType = .date
//                                                quest.assignedDate.year = date.year
//                                                quest.assignedDate.month = date.month
//                                                quest.assignedDate.day = date.day
//                                            }
//                                        }
//                                    }
//                                }
//
//                                return true
//                            }
//                    }
                }
                .listStyle(.plain)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }

            // MARK: Buttons

            VStack(spacing: 10)
            {
                Button
                {
                    switch (status)
                    {
                        case .todo:
                            navPath.append("New Task Todo")
                        case .inProgress:
                            navPath.append("New Task InProgress")
                        case .completed:
                            navPath.append("New Task Completed")
                    }
                }
                label:
                {
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, 15)
                        .padding(.vertical, 15)
                }
                .frame(width: 50, height: 50)
                .buttonStyle(ShadowedBorderCircleButtonStyle())
            }
            .padding(10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
