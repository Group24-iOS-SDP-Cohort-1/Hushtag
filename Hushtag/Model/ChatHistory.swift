import Foundation

// 1. Database Model (Reading data)
nonisolated struct ChatMessageDB: Codable {
    let id: UUID
    let role: Role
    let message: String
    let created_at: Date
}

// 2. Insert Payload (Writing data)
nonisolated struct ChatMessageInsertPayload: Codable {
    let role: Role
    let message: String
}

nonisolated struct Message: Codable {
    let role: String
    let content: String
}
struct GeminiEdgeResponse: Decodable {
    let conversation_id: String
    let message: GeminiResponse
}

nonisolated struct GeminiResponse: Codable {
    let role: String
    let content: String
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
