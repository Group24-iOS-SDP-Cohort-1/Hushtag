import Foundation

nonisolated struct YouTubeUpload: Identifiable, Codable, Sendable {
    let id: UUID
    let userId: UUID?
    let title: String
    let description: String?
    let publishAt: Date?
    let createdAt: Date?
    let uploadStatus: String?
    let youtubeVideoId: String?
    let privacyStatus: String?
    let thumbnailStoragePath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case title
        case description
        case publishAt
        case createdAt
        case uploadStatus
        case youtubeVideoId
        case privacyStatus
        case thumbnailStoragePath
    }

    var effectiveDate: Date {
        return publishAt ?? createdAt ?? Date()
    }
}
