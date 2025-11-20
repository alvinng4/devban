import SwiftUI

struct DevbanTaskAddView: View
{
    init(status: DevbanTask.Status)
    {
        self.viewModel = .init(status: status)
    }

    init(status: DevbanTask.Status, deadline: Date)
    {
        self.viewModel = .init(status: status, deadline: deadline)
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var viewModel: DevbanTaskEditViewModel
    @State private var showReturnAlert: Bool = false
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
                            showReturnAlert = true
                        }
                        label:
                        {
                            Image(systemName: "arrow.backward")
                                .toolBarButtonImage()
                        }
                        .buttonStyle(ShadowedBorderRoundedRectangleButtonStyle())

                        Button("")
                        {
                            showReturnAlert = true
                        }
                        .labelsHidden()
                        .keyboardShortcut(.cancelAction)

                        Spacer()

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

                    // MARK: Save button

                    Button
                    {
                        viewModel.saveTask()
                        dismiss()
                    }
                    label:
                    {
                        Text("Save")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(ShadowedBorderRoundedRectangleButtonStyle())
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
            .alert("Return to last page?", isPresented: $showReturnAlert)
            {
                Button("Cancel", role: .cancel)
                {
                    showReturnAlert = false
                }

                Button("Return", role: .destructive)
                {
                    dismiss()
                }
            }
            message:
            {
                Text("The filled information will be lost.")
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .scrollContentBackground(.hidden)
    }
}
