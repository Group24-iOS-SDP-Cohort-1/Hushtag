import Foundation

nonisolated struct LikedIdeaDB: Codable {
    let id: UUID
    let userId: UUID
    let ideaKey: String
    let title: String
    let description: String?
    let hashtags: [String]?
    let views: Int?
    let likes: Int?
}

nonisolated struct LikedIdeaInsertPayload: Codable {
    let id: UUID
    let userId: UUID
    let ideaKey: String
    let title: String
    let description: String?
    let hashtags: [String]?
    let views: Int?
    let likes: Int?
}

nonisolated struct ConvoResponse: Codable {
    let convoId: UUID?
}
