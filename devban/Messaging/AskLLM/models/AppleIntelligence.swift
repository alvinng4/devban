import FoundationModels
import SwiftUI

extension AskLLMView
{
    /// Manages interactions with Apple's on-device language model.
    ///
    /// This class handles checking model availability, sending prompts, streaming responses,
    /// and managing session state.
    @Observable
    final class AppleIntelligence
    {
        private(set) var responseStatus: ResponseStatus = .idle
        private var session: LanguageModelSession = LanguageModelSession()
        private var streamingTask: Task<Void, Never>?

        /// Checks if Apple Intelligence is available on the device.
        ///
        /// - Throws: NSError with a descriptive message if the model is unavailable
        static func checkModelAvailability() throws
        {
            let msg: String? = switch SystemLanguageModel.default.availability
            {
                case .available:
                    nil
                case .unavailable(.deviceNotEligible):
                    "Your device is not eligible for Apple Intelligence."
                case .unavailable(.appleIntelligenceNotEnabled):
                    "To use this feature, please turn on Apple Intelligence."
                case .unavailable(.modelNotReady):
                    "Model is not ready. Please try again later."
                default:
                    "Apple Intelligence / LLM model is unavailable for unknown reason."
            }

            if let msg
            {
                throw NSError(
                    domain: "Auth",
                    code: 401,
                    userInfo: [
                        NSLocalizedDescriptionKey: msg,
                    ],
                )
            }
        }

        /// Sends a prompt to the language model and streams the response.
        ///
        /// - Parameters:
        ///   - prompt: The text prompt to send to the model
        ///   - onUpdateStreamingContent: Callback invoked with partial content as it streams
        ///   - onFinish: Callback invoked when the response is complete
        ///   - onError: Callback invoked if an error occurs
        func prompt(
            _ prompt: String,
            onUpdateStreamingContent: @escaping (_ partialContent: String) async -> Void,
            onFinish: @escaping () -> Void,
            onError: @escaping (_ error: any Error) -> Void,
        )
        {
            // Check if model is available
            do
            {
                try AppleIntelligence.checkModelAvailability()
            }
            catch
            {
                onError(error)
                return
            }

            guard (responseStatus == .idle)
            else
            {
                onError(
                    NSError(
                        domain: "Auth",
                        code: 401,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "Error: Model is not idle!",
                        ],
                    ),
                )
                return
            }

            // LLM response
            responseStatus = .thinking

            streamingTask = Task
            {
                do
                {
                    let stream = session.streamResponse(to: prompt)

                    for try await partial in stream
                    {
                        responseStatus = .responding
                        await onUpdateStreamingContent(partial.content)
                    }

                    onFinish()

                    responseStatus = .idle
                    streamingTask = nil
                }
                catch
                {
                    onError(error)

                    responseStatus = .idle
                    streamingTask = nil
                }
            }
        }

        /// Stops the current streaming session.
        func stopSession()
        {
            streamingTask?.cancel()
            responseStatus = .idle
            streamingTask = nil
        }

        /// Resets the language model session, clearing conversation history.
        func resetSession()
        {
            session = LanguageModelSession()
        }
    }
}
