import Foundation

nonisolated struct LikedIdeaDB: Codable {
    let id: UUID
    let user_id: UUID
    let ideaKey: String
    let title: String
    let description: String?
    let hashtags: [String]?
}

nonisolated struct LikedIdeaInsertPayload: Codable {
    let id: UUID
    let user_id: UUID
    let ideaKey: String   
    let title: String
    let description: String?
    let hashtags: [String]?
}
