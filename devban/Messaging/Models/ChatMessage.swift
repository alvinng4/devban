import Foundation

/// A structure representing a single chat message.
///
/// - Parameters:
///     - senderId: The sender user id.
///     - content: The message content.
///     - sentDate: Exact timestamp when the message is sent.
///     - messageType: The type of message (user, system, assistant, etc.)
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
        teamId: String? = nil,
        senderId: String,
        content: String,
        sentDate: Date = Date(),
        messageType: MessageType,
    )
    {
        id = UUID()
        self.teamId = teamId
        self.senderId = senderId
        self.content = content
        self.sentDate = sentDate
        self.messageType = messageType
    }

    let id: UUID
    let teamId: String?
    let senderId: String
    let content: String
    let sentDate: Date
    var messageType: MessageType
}
