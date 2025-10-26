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
                        // Bold
                        Button
                        {
                            TextEditingHelper.addBold(
                                text: $viewModel.userInput,
                                selectedRange: $viewModel.userInputSelectedRange,
                            )
                        }
                        label:
                        {
                            Image(systemName: "bold")
                                .textEditorToolBarButtonImage(width: 13.0, height: 13.0)
                        }

                        // italic
                        Button
                        {
                            TextEditingHelper.addItalic(
                                text: $viewModel.userInput,
                                selectedRange: $viewModel.userInputSelectedRange,
                            )
                        }
                        label:
                        {
                            Image(systemName: "italic")
                                .textEditorToolBarButtonImage(width: 13.0, height: 13.0)
                        }

                        // strike-through
                        Button
                        {
                            TextEditingHelper.addStrikeThrough(
                                text: $viewModel.userInput,
                                selectedRange: $viewModel.userInputSelectedRange,
                            )
                        }
                        label:
                        {
                            Image(systemName: "strikethrough")
                                .textEditorToolBarButtonImage(width: 15.0, height: 15.0)
                        }

                        // in-line code
                        Button
                        {
                            TextEditingHelper.addInlineCode(
                                text: $viewModel.userInput,
                                selectedRange: $viewModel.userInputSelectedRange,
                            )
                        }
                        label:
                        {
                            Image(.codeSymbol)
                                .textEditorToolBarButtonImage()
                        }

                        // unordered list
                        Button
                        {
                            TextEditingHelper.addUnorderedList(
                                text: $viewModel.userInput,
                                selectedRange: $viewModel.userInputSelectedRange,
                            )
                        }
                        label:
                        {
                            Image(systemName: "list.bullet")
                                .textEditorToolBarButtonImage()
                        }

                        // check list
                        Button
                        {
                            TextEditingHelper.addCheckList(
                                text: $viewModel.userInput,
                                selectedRange: $viewModel.userInputSelectedRange,
                            )
                        }
                        label:
                        {
                            Image(systemName: "checklist")
                                .textEditorToolBarButtonImage()
                        }

                        // link
                        Button
                        {
                            TextEditingHelper.addLink(
                                text: $viewModel.userInput,
                                selectedRange: $viewModel.userInputSelectedRange,
                            )
                        }
                        label:
                        {
                            Image(systemName: "link")
                                .textEditorToolBarButtonImage()
                        }

                        Spacer()
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
                        CustomTextEditor(text: $viewModel.userInput, selectedRange: $viewModel.userInputSelectedRange)
                            .padding(.leading, 8)

                        // Submit button
                        VStack(spacing: 0)
                        {
                            Spacer()

                            Button
                            {
                                viewModel.sendMessage()
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
            .padding()
        }
    }
}
