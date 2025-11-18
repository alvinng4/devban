import Foundation

/// A structure representing a single chat message.
///
/// - Parameters:
///     - senderID: The sender user id.
///     - content: The message content.
///     - sentDate: Exact timestamp when the message is sent.
///     - LLMContextClearedAfter: For LLM, is context cleared after this message.
struct ChatMessage: Codable, Equatable, Identifiable
{
    /// Message types for devban chat messages
    enum MessageType: String, Codable
    {
        /// User message
        case user
        /// System messages (e.g. Error)
        case system
        /// LLM Response
        case assistantResponse
        /// LLM Greetings
        case assistantGreeting
        /// Pseudo-message representing LLM context clear
        case assistantContextClear
    }

    init(
        senderID: String?,
        content: String,
        sentDate: Date = Date(),
        messageType: MessageType,
    )
    {
        id = UUID()
        self.senderID = senderID
        self.content = content
        self.sentDate = sentDate
        self.messageType = messageType
    }

    let id: UUID
    let senderID: String?
    let content: String
    let sentDate: Date
    var messageType: MessageType
}
