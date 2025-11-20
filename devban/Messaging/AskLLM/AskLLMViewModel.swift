import FirebaseFirestore
import FirebaseSharedSwift
import SwiftUI

extension AskLLMView
{
    /// ViewModel for AskLLM.
    @Observable
    final class AskLLMViewModel
    {
        init()
        {
            guard let uid: String = DevbanUserContainer.shared.getUid()
            else
            {
                messages = [
                    ChatMessage(
                        senderId: "",
                        content: "Error: Failed to get user ID",
                        messageType: .system,
                    ),
                ]
                return
            }

            Task
            {
                do
                {
                    let transcript: [ChatMessage] = try await AskLLMViewModel.getTranscriptFromDatabase(uid: uid)
                    if (transcript.isEmpty)
                    {
                        let newMessage: ChatMessage = AskLLMViewModel.getGreetings(uid: uid)
                        AskLLMViewModel.addMessageToDatabase(uid: uid, msg: newMessage)
                        messages = try await AskLLMViewModel.getTranscriptFromDatabase(uid: uid)
                    }
                    else if (transcript.last?.messageType != .assistantGreeting || transcript.last?
                        .messageType != .assistantContextClear)
                    {
                        let newMessage: ChatMessage = .init(
                            senderId: uid,
                            content: "",
                            messageType: .assistantContextClear,
                        )
                        AskLLMViewModel.addMessageToDatabase(uid: uid, msg: newMessage)
                        messages = try await AskLLMViewModel.getTranscriptFromDatabase(uid: uid)
                    }
                    else
                    {
                        messages = transcript
                    }
                }
                catch
                {
                    print("AskLLMViewModel init Error: \(error.localizedDescription)")
                }
            }
        }

        var userInput: String = ""
        var userInputSelectedRange = NSRange(location: 0, length: 0)

        private(set) var messages: [ChatMessage] = []
        private(set) var model: AppleIntelligence = .init()
        private(set) var streamingContent: String = ""

        static func getGreetings(uid: String) -> ChatMessage
        {
            return ChatMessage(
                senderId: uid,
                content: "Hello! How may I assist you today?",
                messageType: .assistantGreeting,
            )
        }

        static func getTranscriptFromDatabase(uid: String) async throws -> [ChatMessage]
        {
            return try await AskLLMViewModel.getAskLLMTranscriptCollection()
                .whereField("sender_id", isEqualTo: uid)
                .order(by: "sent_date")
                .getDocuments(as: ChatMessage.self)
        }

        static func getAskLLMTranscriptCollection() -> CollectionReference
        {
            return Firestore.firestore().collection("askllm_transcripts")
        }

        var disableSubmit: Bool
        {
            return model.responseStatus != .idle || userInput.isEmptyOrWhitespace()
        }

        func sendMessage()
        {
            guard !disableSubmit,
                  let uid = DevbanUserContainer.shared.getUid()
            else
            {
                return
            }

            let trimmed: String = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }

            let newMessage: ChatMessage = .init(senderId: uid, content: trimmed, messageType: .user)
            AskLLMViewModel.addMessageToDatabase(uid: uid, msg: newMessage)
            userInput = ""

            Task
            {
                do
                {
                    messages = try await AskLLMViewModel.getTranscriptFromDatabase(uid: uid)
                }
                catch
                {
                    print("sendMessage Error: \(error.localizedDescription)")
                }

                // Get response from LLM
                promptLLM(trimmed, uid: uid)
            }
        }

        private static func addMessageToDatabase(uid _: String, msg: ChatMessage)
        {
            let doc: DocumentReference = AskLLMViewModel.getAskLLMTranscriptCollection().document(msg.id.uuidString)
            do
            {
                try doc.setData(
                    from: msg,
                    merge: false,
                    encoder: encoder,
                )
            }
            catch
            {
                print("addMessageToDatabase Error: \(error.localizedDescription)")
            }
        }

        private func promptLLM(_ prompt: String, uid: String)
        {
            self.streamingContent = ""
            model.prompt(prompt)
            { partialContent in
                let previousOutputLength: Int = self.streamingContent.count

                // When the message is short, render character by character.
                // When it is long, render chunk by chunk to prevent lag.
                if (previousOutputLength < 500)
                {
                    // Get only the new characters since last update
                    let newCharacters = String(partialContent.dropFirst(previousOutputLength))

                    // Append character by character with small delay so that the display look smooth
                    for character in newCharacters
                    {
                        self.streamingContent.append(character)
                        do
                        {
                            try await Task.sleep(nanoseconds: 100_000) // 0.1 ms
                        }
                        catch
                        {
                            print("model.prompt Error: \(error.localizedDescription)")
                        }
                    }
                }
                else
                {
                    self.streamingContent = partialContent
                }
            }
            onFinish:
            {
                self.messages.append(
                    ChatMessage(
                        senderId: uid,
                        content: self.streamingContent.trimmingCharacters(in: .whitespacesAndNewlines),
                        messageType: .assistantResponse,
                    ),
                )

                Task
                {
                    do
                    {
                        let newMessage: ChatMessage = .init(
                            senderId: uid,
                            content: self.streamingContent.trimmingCharacters(in: .whitespacesAndNewlines),
                            messageType: .assistantResponse,
                        )
                        AskLLMViewModel.addMessageToDatabase(uid: uid, msg: newMessage)
                        self.streamingContent = ""
                        self.messages = try await AskLLMViewModel.getTranscriptFromDatabase(uid: uid)
                    }
                    catch
                    {
                        print("onFinish Error: \(error.localizedDescription)")
                    }
                }
            }
            onError:
            { error in
                if (!self.streamingContent.isEmptyOrWhitespace())
                {
                    let newMessage: ChatMessage = .init(
                        senderId: uid,
                        content: self.streamingContent.trimmingCharacters(in: .whitespacesAndNewlines),
                        messageType: .assistantResponse,
                    )
                    AskLLMViewModel.addMessageToDatabase(uid: uid, msg: newMessage)
                    self.streamingContent = ""
                }
                print("Error detected: \(error.localizedDescription)")
                let newMessage: ChatMessage = .init(
                    senderId: uid,
                    content: "Error: \(error.localizedDescription)",
                    messageType: .system,
                )
                AskLLMViewModel.addMessageToDatabase(uid: uid, msg: newMessage)

                Task
                {
                    do
                    {
                        self.messages = try await AskLLMViewModel.getTranscriptFromDatabase(uid: uid)
                    }
                    catch
                    {
                        print(error.localizedDescription)
                    }
                }
            }
        }

        func resetSession()
        {
            model.stopSession()
            guard let uid = DevbanUserContainer.shared.getUid()
            else
            {
                print("Error!")
                return
            }

            Task
            {
                await waitForIdle()
                model.resetSession()

                do
                {
                    let querySnapshot = try await AskLLMViewModel.getAskLLMTranscriptCollection()
                        .whereField("sender_id", isEqualTo: uid)
                        .getDocuments()

                    let batch = Firestore.firestore().batch()

                    for document in querySnapshot.documents
                    {
                        batch.deleteDocument(document.reference)
                    }

                    try await batch.commit()
                    print("AskLLM: records successfully deleted")
                }
                catch
                {
                    print("AskLLM: Error deleting documents: \(error)")
                }

                let newMessage: ChatMessage = AskLLMViewModel.getGreetings(uid: uid)
                AskLLMViewModel.addMessageToDatabase(uid: uid, msg: newMessage)
                messages = try await AskLLMViewModel.getTranscriptFromDatabase(uid: uid)
            }
        }

        func stopModel()
        {
            model.stopSession()
        }

        func clearContext()
        {
            guard let uid = DevbanUserContainer.shared.getUid()
            else
            {
                print("Error!")
                return
            }

            model.stopSession()

            Task
            {
                await waitForIdle()
                model.resetSession()
                await MainActor.run
                {
                    let newMessage: ChatMessage = .init(
                        senderId: uid,
                        content: "",
                        messageType: .assistantContextClear,
                    )
                    AskLLMViewModel.addMessageToDatabase(uid: uid, msg: newMessage)

                    Task
                    {
                        do
                        {
                            self.messages = try await AskLLMViewModel.getTranscriptFromDatabase(uid: uid)
                        }
                        catch
                        {
                            print("clearContext Error: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }

        private func waitForIdle(timeoutSeconds: TimeInterval = 5.0) async
        {
            let timeoutNanoseconds = UInt64(timeoutSeconds * 1_000_000_000)
            let checkInterval: UInt64 = 100_000_000 // 0.1 seconds
            var elapsed: UInt64 = 0

            while (model.responseStatus != .idle), (elapsed < timeoutNanoseconds)
            {
                try? await Task.sleep(nanoseconds: checkInterval)
                elapsed += checkInterval
            }
        }

        private static var encoder: Firestore.Encoder
        {
            let encoder = Firestore.Encoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return encoder
        }
    }
}
