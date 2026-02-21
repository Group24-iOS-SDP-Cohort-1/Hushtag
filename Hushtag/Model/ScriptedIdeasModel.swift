import Foundation

// 1. The UI Model
nonisolated struct ScriptedIdea: Identifiable, Codable, Sendable {
    let id: UUID
    let chat_id: UUID
    var title: String?
    var description: String?
    var script: String?
    var thumbnailURL: String?
    var tags: [String]?
    var mockTitle: String?
    var mockDescription: String?
}

// 2. The Database Model
nonisolated struct ScriptedIdeaDB: Codable, Sendable {
    let id: UUID
    let chat_id: UUID
    let title: String?
    let description: String?
    let script: String?
    let thumbnail: String?
    let tags: [String]?
    let mock_title: String?
    let mock_description: String?
}

// 3. The Insert Payload
nonisolated struct ScriptedIdeaInsertPayload: Codable, Sendable {
    let user_id: UUID
    let chat_id: UUID
    let title: String?
    let description: String?
    let script: String?
    let thumbnail: String?
    let hashtags: [String]? 
    let mock_title: String?
    let mock_description: String?
}

nonisolated struct ChatMessageDB: Codable, Identifiable {
    let id: UUID
    let conversation_id: UUID
    let role: Role
    let content: String
    let created_at: Date?
}

// 2. Insert Payload (Writing data)
nonisolated struct ChatMessageInsertPayload: Codable {
    let conversation_id: UUID
    let role: Role
    let content: String
}

nonisolated struct Message: Codable {
    let role: String
    let content: String
    var mark: String?
}
struct GeminiEdgeResponse: Decodable {
    let conversation_id: String
    let message: GeminiResponse
}

nonisolated struct GeminiResponse: Codable {
    let role: String
    let content: String
}

nonisolated struct Conversation: Codable {
    let id: UUID
    let user_id: UUID
    let title: String?
    let created_at: Date?
}

nonisolated struct ConversationInsertPayload: Codable {
    let id: UUID
    let user_id: UUID
}

enum Role: String, Codable {
    case bot
    case user
    case system
    var desciption: String {
        switch self {
        case .bot: return "bot"
        case .user: return "user"
        case .system: return "system"
        }
    }
}
