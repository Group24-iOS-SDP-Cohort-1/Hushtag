import Foundation

struct Profile: Identifiable, Sendable {
    let id: UUID
    var fullName: String
    var email: String
    var avatarURL: String?
    var isYouTubeConnected: Bool
}

nonisolated struct ProfileDB: Codable, Sendable {
    let id: UUID
    let user_id: UUID
    let full_name: String
    let email: String
    let avatar_url: String?
    let is_youtube_connected: Bool?
}

nonisolated struct ProfileUpdatePayload: Encodable, Sendable {
    let full_name: String
    let avatar_url: String?
}

nonisolated struct ProfileInsertPayload: Encodable, Sendable {
    let user_id: UUID
    let full_name: String
    let email: String
    let avatar_url: String?
}
