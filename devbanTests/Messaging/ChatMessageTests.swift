import Foundation
import Testing
@testable import devban

/// Unit tests for the `ChatMessage` model.
/// Verifies initialization and default values for chat messages.
struct ChatMessageTests {

    // MARK: - Init / stored properties

    /// Stores all provided values exactly as given.
    @Test
    func init_usesProvidedValues() throws {
        let idTeam = "team-123"
        let senderId = "user-456"
        let content = "Hello, devban!"
        let sentDate = Date(timeIntervalSince1970: 1_700_000_000)
        let messageType: ChatMessage.MessageType = .assistantResponse

        let message = ChatMessage(
            teamId: idTeam,
            senderId: senderId,
            content: content,
            sentDate: sentDate,
            messageType: messageType
        )

        #expect(message.teamId == idTeam)
        #expect(message.senderId == senderId)
        #expect(message.content == content)
        #expect(message.sentDate == sentDate)
        #expect(message.messageType == messageType)
    }

    /// Generates a unique identifier for each new message.
    @Test
    func init_generatesUniqueIds() throws {
        let message1 = ChatMessage(
            teamId: nil,
            senderId: "user-1",
            content: "First",
            messageType: .user
        )

        let message2 = ChatMessage(
            teamId: nil,
            senderId: "user-1",
            content: "Second",
            messageType: .user
        )

        #expect(message1.id != message2.id)
    }

    /// Uses the current date as the default sent date when not provided.
    @Test
    func init_usesCurrentDateWhenSentDateOmitted() throws {
        let before = Date()
        let message = ChatMessage(
            teamId: nil,
            senderId: "user-1",
            content: "Now",
            messageType: .user
        )
        let after = Date()

        #expect(message.sentDate >= before && message.sentDate <= after)
    }

    /// Supports all defined message types.
    @Test
    func messageType_supportsAllCases() throws {
        let types: [ChatMessage.MessageType] = [
            .user,
            .system,
            .assistantResponse,
            .assistantGreeting,
            .assistantContextClear
        ]

        for type in types {
            let message = ChatMessage(
                teamId: nil,
                senderId: "user-1",
                content: "Test",
                messageType: type
            )

            #expect(message.messageType == type)
        }
    }
}
