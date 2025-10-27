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
    init(
        senderID: UUID?,
        content: String,
        sentDate: Date = Date(),
        LLMContextClearedAfter: Bool = false,
    )
    {
        id = UUID()
        self.senderID = senderID
        self.content = content
        self.sentDate = sentDate
        self.LLMContextClearedAfter = LLMContextClearedAfter
    }

    let id: UUID
    let senderID: UUID?
    let content: String
    let sentDate: Date
    var LLMContextClearedAfter: Bool
}
