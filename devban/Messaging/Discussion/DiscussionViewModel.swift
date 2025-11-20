import Combine
import FirebaseFirestore
import FirebaseSharedSwift
import SwiftUI

extension DiscussionView
{
    /// ViewModel for AskLLM.
    @Observable
    final class DiscussionViewModel
    {
        init()
        {
            guard let teamId: String = DevbanUserContainer.shared.getTeamId()
            else
            {
                return
            }

            let (publisher, listener) = Firestore.firestore().collection("discussion")
                .whereField("team_id", isEqualTo: teamId)
                .order(by: "sent_date")
                .addSnapshotListener(as: ChatMessage.self)

            self.messagesListener = listener
            publisher
                .receive(on: DispatchQueue.main)
                .sink
                { completion in
                    if case let .failure(error) = completion
                    {
                        print("Listener error: \(error)")
                    }
                }
                receiveValue:
                { [weak self] chatMessages in
                    self?.messages = chatMessages
                }
                .store(in: &cancellables)
        }

        deinit
        {
            messagesListener?.remove()
        }

        var userInput: String = ""
        var userInputSelectedRange = NSRange(location: 0, length: 0)

        private(set) var messages: [ChatMessage] = []
        private var messagesListener: ListenerRegistration?
        private var cancellables: Set<AnyCancellable> = .init()

        var disableSubmit: Bool
        {
            return userInput.isEmptyOrWhitespace()
        }

        func sendMessage()
        {
            guard !disableSubmit,
                  let uid = DevbanUserContainer.shared.getUid(),
                  let teamId: String = DevbanUserContainer.shared.getTeamId()
            else
            {
                return
            }

            let trimmed: String = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }

            let newMessage: ChatMessage = .init(teamId: teamId, senderId: uid, content: trimmed, messageType: .user)
            let doc: DocumentReference = Firestore.firestore().collection("discussion")
                .document(newMessage.id.uuidString)
            do
            {
                try doc.setData(
                    from: newMessage,
                    merge: false,
                    encoder: DiscussionViewModel.encoder,
                )
            }
            catch
            {
                print("sendMessage Error: \(error.localizedDescription)")
            }

            userInput = ""
        }

        private static var encoder: Firestore.Encoder
        {
            let encoder = Firestore.Encoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return encoder
        }
    }
}
