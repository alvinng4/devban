import FoundationModels
import SwiftUI

extension AskLLMView
{
    @Observable
    final class AppleIntelligence
    {
        private(set) var responseStatus: ResponseStatus = .idle
        private var session: LanguageModelSession = LanguageModelSession()
        private var streamingTask: Task<Void, Never>?

        static func checkModelAvailability() throws
        {
            let msg: String? = switch SystemLanguageModel.default.availability
            {
                case .available:
                    nil
                case .unavailable(.deviceNotEligible):
                    "Error: Your device is not eligible for Apple Intelligence."
                case .unavailable(.appleIntelligenceNotEnabled):
                    "Error: To use this feature, please turn on Apple Intelligence."
                case .unavailable(.modelNotReady):
                    "Error: Model is not ready. Please try again later."
                default:
                    "Error: Apple Intelligence / LLM model is unavailable for unknown reason."
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

        func stopSession()
        {
            streamingTask?.cancel()
            responseStatus = .idle
            streamingTask = nil
        }
        
        func resetSession()
        {
            session = LanguageModelSession()
        }
    }
}
