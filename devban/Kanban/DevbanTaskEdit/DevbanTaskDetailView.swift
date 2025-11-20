import SwiftUI

/// View for viewing and editing an existing task's details.
struct DevbanTaskDetailView: View
{
    init(devbanTask: DevbanTask)
    {
        self.viewModel = .init(devbanTask: devbanTask)
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var viewModel: DevbanTaskEditViewModel
    @State private var showDeleteAlert: Bool = false
    @FocusState private var isTextFocused: Bool

    var body: some View
    {
        let isCompact: Bool = (horizontalSizeClass == .compact)

        ZStack
        {
            ThemeManager.shared.backgroundColor
                .ignoresSafeArea()

            ScrollView
            {
                VStack(spacing: 10)
                {
                    // MARK: Tool bar

                    HStack
                    {
                        // MARK: Back button

                        Button
                        {
                            dismiss()
                        }
                        label:
                        {
                            Image(systemName: "arrow.backward")
                                .toolBarButtonImage()
                        }
                        .buttonStyle(ShadowedBorderRoundedRectangleButtonStyle())

                        Button("")
                        {
                            dismiss()
                        }
                        .labelsHidden()
                        .keyboardShortcut(.cancelAction)

                        Spacer()

                        // Delete Button
                        Button
                        {
                            showDeleteAlert = true
                            HapticManager.shared.playWarningNotification()
                        }
                        label:
                        {
                            Image(systemName: "trash")
                                .toolBarButtonImage()
                        }
                        .buttonStyle(ShadowedBorderRoundedRectangleButtonStyle())

                        // Pin button
                        Button
                        {
                            viewModel.devbanTask.isPinned.toggle()
                            viewModel.updateIsPinned()
                        }
                        label:
                        {
                            Image(systemName: viewModel.devbanTask.isPinned ? "pin.fill" : "pin")
                                .toolBarButtonImage()
                                .rotationEffect(.degrees(45))
                        }
                        .buttonStyle(
                            ShadowedBorderRoundedRectangleButtonStyle(
                                stayPressed: viewModel.devbanTask.isPinned,
                            ),
                        )

                        // Keyboard down button
                        Button
                        {
                            isTextFocused = false
                        }
                        label:
                        {
                            Image(systemName: "keyboard.chevron.compact.down")
                                .toolBarButtonImage()
                        }
                        .buttonStyle(ShadowedBorderRoundedRectangleButtonStyle())
                    }

                    Text("New task")
                        .customTitle()

                    DevbanTaskEditView(
                        viewModel: $viewModel,
                        isTextFocused: $isTextFocused,
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding()
                    .shadowedBorderRoundedRectangle()
                    .padding(.bottom, 5)
                }
                .frame(maxWidth: NeobrutalismConstants.maxWidthMedium)
                .padding(
                    .horizontal,
                    isCompact ?
                        NeobrutalismConstants.mainContentPaddingHorizontalCompact :
                        NeobrutalismConstants.mainContentPaddingHorizontalRegular,
                )
                .padding(
                    .vertical,
                    isCompact ?
                        NeobrutalismConstants.mainContentPaddingVerticalCompact :
                        NeobrutalismConstants.mainContentPaddingVerticalRegular,
                )
                .frame(maxWidth: .infinity, alignment: .center) // For scroll bar to be on edge
            }
            .alert(
                "Confirm delete",
                isPresented: $showDeleteAlert,
            )
            {
                Button("Delete", role: .destructive)
                {
                    viewModel.deleteTask()
                    dismiss()
                }
                Button("Cancel", role: .cancel)
                {
                    showDeleteAlert = false
                }
            }
            message:
            {
                Text("This action is permanant and cannot be undone.")
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .scrollContentBackground(.hidden)
    }
}
