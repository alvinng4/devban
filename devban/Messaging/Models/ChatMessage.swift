import Foundation

/// A structure representing a single chat message.
///
/// - Parameters:
///     - senderID: The sender user id.
///     - content: The message content
///     - sentDate: Exact timestamp when the message is sent.
struct ChatMessage: Identifiable, Codable
{
    init(
        senderID: UUID?,
        content: String,
        sentDate: Date = Date(),
    )
    {
        id = UUID()
        self.senderID = senderID
        self.content = content
        self.sentDate = sentDate
    }

    let id: UUID
    let senderID: UUID?
    let content: String
    let sentDate: Date
}
