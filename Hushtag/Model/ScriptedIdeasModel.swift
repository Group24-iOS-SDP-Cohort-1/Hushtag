import Foundation

/// 1. The UI Model
nonisolated struct ScriptedIdea: Identifiable, Codable {
    let id: UUID
    let chatId: UUID
    var title: String?
    var description: String?
    var script: String?
    var thumbnail: String?
    var tags: [String]?
    let idea_id: UUID?
}

/// 2. The Database Model
nonisolated struct ScriptedIdeaDB: Codable {
    let id: UUID
    let chatId: UUID
    let title: String?
    let description: String?
    let script: String?
    let thumbnail: String?
    let tags: [String]?
    let idea_id: UUID?
}

/// 3. The Insert Payload
nonisolated struct ScriptedIdeaInsertPayload: Codable {
    let userId: UUID
    let chat_id: UUID
    let title: String?
    let description: String?
    let script: String?
    let thumbnail: String?
    let hashtags: [String]?
}

nonisolated struct ChatMessageDB: Codable, Identifiable {
    let id: UUID
    let conversationId: UUID
    let role: Role
    let content: String
    let created_at: Date?
}

enum ScriptSection {
    case title
    case description
    case script
    case buttons
}

/// 2. Insert Payload (Writing data)
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
    let conversationId: String
    let message: GeminiResponse
}

nonisolated struct GeminiResponse: Codable {
    let role: String
    let content: String
}

nonisolated struct Conversation: Codable {
    let id: UUID
    let userId: UUID
    let title: String?
    let createdAt: Date?
    let ideaId: UUID?
    let scriptedIdeas: ScriptedIdeaDB?

    var hasStar: Bool {
        guard let idea = scriptedIdeas else { return false }

        return idea.title != nil ||
            idea.description != nil ||
            idea.script != nil ||
            idea.thumbnail != nil
    }
}

extension Conversation {
    var milestoneCount: Int {
        guard let idea = scriptedIdeas else { return 0 }
        var count = 0
        if idea.script != nil { count += 1 }
        if idea.title != nil { count += 1 }
        if idea.description != nil { count += 1 }
        return count
    }
}

nonisolated struct ConversationInsertPayload: Codable {
    let id: UUID
    let userId: UUID
    let ideaId: UUID?
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
