import FoundationModels
import SwiftUI

/// Renders the user interface for AskLLM.
struct AskLLMView: View
{
    init()
    {
        viewModel = AskLLMViewModel()
    }

    @State private var viewModel: AskLLMViewModel

    var body: some View
    {
        ZStack
        {
            ThemeManager.shared.backgroundColor

            VStack(spacing: 10)
            {
                Text("AskLLM")
                    .customTitle()

                VStack(spacing: 0)
                {
                    // TODO: Change the senderID to actual user ID after User is implemented
                    // MARK: Renders the chat messages

                    ChatMessagesView(
                        messages: viewModel.messages,
                        isLoading: viewModel.isThinking,
                        LLMStreamingContent: viewModel.LLMStreamingContent,
                        userInput: viewModel.userInput,
                    )

                    // MARK: User text editor

                    VStack
                    {
                        Divider()
                            .padding(.vertical, 2)
                            .foregroundStyle(.secondary)

                        // MARK: Tool bar for text editing

                        HStack(spacing: 16)
                        {
                            // Stop model
                            Button
                            {
                                viewModel.stopModel()
                            }
                            label:
                            {
                                Image(systemName: "stop.circle")
                                    .textEditorToolBarButtonImage()
                            }

                            // Clear context
                            Button
                            {
                                viewModel.clearContext()
                            }
                            label:
                            {
                                Image(systemName: "paintbrush.fill")
                                    .textEditorToolBarButtonImage()
                            }

                            // Restart conversation
                            Button
                            {
                                viewModel.restart()
                            }
                            label:
                            {
                                Image(systemName: "clear")
                                    .textEditorToolBarButtonImage()
                            }

                            Spacer()

                            // Remove keyboard
                            Button
                            {
                                TextEditingHelper.resetFocus()
                            }
                            label:
                            {
                                Image(systemName: "keyboard.chevron.compact.down")
                                    .textEditorToolBarButtonImage()
                            }
                        }
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.horizontal, 8)

                        Divider()
                            .padding(.vertical, 2)
                            .foregroundStyle(.secondary)

                        // MARK: Text editor

                        HStack
                        {
                            CustomTextEditor(
                                text: $viewModel.userInput,
                                selectedRange: $viewModel.userInputSelectedRange,
                            )
                            .padding(.leading, 8)

                            // Submit button
                            VStack(spacing: 0)
                            {
                                Spacer()

                                Button
                                {
                                    viewModel.sendMessage()
                                    TextEditingHelper.resetFocus()
                                }
                                label:
                                {
                                    HStack(spacing: 5)
                                    {
                                        Image(systemName: "pointer.arrow.ipad")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 15, height: 15)
                                            .rotationEffect(.degrees(70))

                                        Text("Submit")
                                            .lineLimit(1)
                                            .font(.system(size: 15))
                                    }
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 12)
                                    .foregroundStyle(.white)
                                    .background(ThemeManager.shared.buttonColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .padding(.trailing, 5)
                                }
                                .keyboardShortcut(.defaultAction)
                            }
                            .padding(.bottom, 10)
                        }
                        .frame(height: 120)
                    }
                }
                .shadowedBorderRoundedRectangle()
            }
            .frame(maxWidth: NeobrutalismConstants.maxWidthLarge)
            .padding(.horizontal, NeobrutalismConstants.mainContentPaddingHorizontal)
            .padding(.vertical, NeobrutalismConstants.mainContentPaddingVertical)
        }
    }
}
