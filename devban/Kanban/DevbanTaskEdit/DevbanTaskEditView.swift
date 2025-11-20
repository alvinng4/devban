import SwiftUI

struct DevbanTaskEditView: View
{
    @Environment(\.colorScheme) private var colorScheme

    @Binding var viewModel: DevbanTaskEditViewModel
    @FocusState.Binding var isTextFocused: Bool

    var body: some View
    {
        VStack(spacing: 0)
        {
            // MARK: Task title

            Text("Task title")
                .fontDesign(.rounded)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.bottom, 4)

            TextField(
                "Title",
                text: $viewModel.devbanTask.title,
                axis: .vertical,
            )
            .font(.headline)
            .focused($isTextFocused)
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.black, lineWidth: 2),
            )
            .padding(.bottom)
            .onChange(of: viewModel.devbanTask.title)
            {
                viewModel.updateTitle()
            }

            // MARK: task description

            Text("Description")
                .fontDesign(.rounded)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.bottom, 4)

            TextField("Description", text: $viewModel.devbanTask.description, axis: .vertical)
                .font(.headline)
                .focused($isTextFocused)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.black, lineWidth: 2),
                )
                .padding(.bottom)
                .onChange(of: viewModel.devbanTask.description)
                {
                    viewModel.updateDescription()
                }

            // MARK: Status

            HStack
            {
                Text("Status")
                    .fontDesign(.rounded)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                Menu
                {
                    Picker("Status", selection: $viewModel.devbanTask.status)
                    {
                        ForEach(DevbanTask.Status.allCases)
                        { status in
                            Text(status.description)
                                .tag(status)
                        }
                    }
                }
                label:
                {
                    HStack(spacing: 5)
                    {
                        Text(viewModel.devbanTask.status.description)
                        Image(systemName: "chevron.up.chevron.down")
                    }
                    .fontDesign(.rounded)
                }
                .tint(.primary)
                .onChange(of: viewModel.devbanTask.status)
                {
                    viewModel.updateStatus()
                }
            }

            // MARK: Difficulty

            VStack(spacing: 5)
            {
                HStack
                {
                    Text("Difficulty")
                        .fontDesign(.rounded)
                        .frame(maxWidth: .infinity, alignment: .topLeading)

                    Text(viewModel.devbanTask.difficulty.description)
                        .foregroundStyle(viewModel.devbanTask.difficulty.getColor())
                }

                Slider(
                    value: $viewModel.difficultyValue,
                    in: 0 ... 4,
                )
                { isEditing in
                    if (!isEditing)
                    {
                        viewModel.updateDifficulty() // For database
                    }
                }
                .onChange(of: viewModel.difficultyValue)
                {
                    viewModel.updateDifficultyUI() // For UI update
                }
                .padding(10)
                .tint(viewModel.devbanTask.difficulty.getColor())
                .overlay(
                    RoundedRectangle(cornerRadius: 6.0)
                        .stroke(.black, lineWidth: 2.0),
                )
            }
            .padding(.vertical, 8)

            // MARK: Deadline

            VStack(spacing: 5)
            {
                HStack
                {
                    Text("Deadline")
                        .fontDesign(.rounded)
                        .frame(maxWidth: .infinity, alignment: .topLeading)

                    Toggle("", isOn: $viewModel.devbanTask.hasDeadline)
                        .onChange(of: viewModel.devbanTask.hasDeadline)
                        {
                            viewModel.updateHasDeadline() // For UI update
                        }
                }

                if (viewModel.devbanTask.hasDeadline)
                {
                    DatePicker(
                        "At",
                        selection: $viewModel.devbanTask.deadline,
                        displayedComponents: [.date, .hourAndMinute],
                    )
                    .datePickerStyle(.compact)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.black, lineWidth: 2),
                    )
                    .onChange(of: viewModel.devbanTask.deadline)
                    {
                        viewModel.updateDeadline()
                    }
                }
            }
            .padding(.vertical, 8)

            // MARK: Progress

            VStack(spacing: 5)
            {
                Text("Progress bar")
                    .fontDesign(.rounded)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                HStack
                {
                    Slider(
                        value: $viewModel.devbanTask.progress,
                        in: 0 ... 100,
                    )
                    { isEditing in
                        if (!isEditing)
                        {
                            viewModel.updateProgress()
                        }
                    }
                    .tint(viewModel.devbanTask.difficulty.getColor())

                    Text("\(Int(viewModel.devbanTask.progress))%")
                }
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.black, lineWidth: 2),
                )
            }
            .padding(.vertical, 8)
        }
    }
}
