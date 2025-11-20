import SwiftUI

struct DevbanTaskDetailView: View
{
    init(devbanTask: DevbanTask)
    {
        self.viewModel = .init(devbanTask: devbanTask)
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var viewModel: DevbanTaskEditViewModel
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

                        // Pin button
                        Button
                        {
                            viewModel.togglePin()
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

                    Text("Task")
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
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .scrollContentBackground(.hidden)
    }
}
