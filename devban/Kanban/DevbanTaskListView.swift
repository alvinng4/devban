import SwiftUI

struct DevbanTaskListView: View
{
    init(status: DevbanTask.Status, navPath: Binding<NavigationPath>, isDraggable: Bool = true)
    {
        self.viewModel = .init(status: status)
        _navPath = navPath
        self.isDraggable = isDraggable
    }

    @State private var viewModel: DevbanTaskListViewModel
    @Binding private var navPath: NavigationPath
    private let isDraggable: Bool

    var body: some View
    {
        ZStack
        {
            GeometryReader
            { proxy in
                List
                {
                    ForEach(viewModel.devbanTasks, id: \.self)
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
                                Task
                                {
                                    do
                                    {
                                        try await DevbanTask.deleteTask(id: devbanTask.id)
                                    }
                                    catch
                                    {
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                            .tint(.red)
                        }
                        .customDraggable(
                            isDraggable: isDraggable,
                            transferString: "Task \(devbanTask.id)",
                        )
                    }

                    if (isDraggable)
                    {
                        Color.clear
                            .frame(height: max(
                                0.0,
                                proxy.size.height - 100.0 - CGFloat(viewModel.devbanTasks.count) * 50.0,
                            ))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                                                    data: ["status": viewModel.status.rawValue],
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
                    }
                }
                .listStyle(.plain)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }

            // MARK: Buttons

            VStack(spacing: 10)
            {
                Button
                {
                    switch (viewModel.status)
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
