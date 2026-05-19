import Foundation

struct Profile: Identifiable {
    let id: UUID
    var fullName: String
    var email: String
    var avatarURL: String?
    var isYouTubeConnected: Bool
}

nonisolated struct ProfileDB: Codable {
    let id: UUID
    let userId: UUID
    let fullName: String
    let email: String
    let avatarUrl: String?
    let isYoutubeConnected: Bool?
}

nonisolated struct ProfileUpdatePayload: Encodable {
    let fullName: String
    let avatarUrl: String?
}

nonisolated struct ProfileInsertPayload: Encodable {
    let userId: UUID
    let fullName: String
    let email: String
    let avatarUrl: String?
}

