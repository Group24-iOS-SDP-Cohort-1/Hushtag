import Foundation

nonisolated struct AudienceMetrics: Codable, Sendable {
    let user_id: UUID
    let views: Int
    let likes: Int
    let estimated_minutes_watched: Int
    let start_date: String
    let end_date: String
}

enum AnalysisMetric {
    case views
    case likes
    case watchTime
}

nonisolated struct LatestContent: Decodable {
    let video_id: String
    let title: String
    let views: Int
    let likes: Int
    let thumbnail: String
    let published_at: Date
    let duration_seconds: Int
    let fetched_at: String
}

nonisolated struct TopVideo: Decodable {
    let video_id: String
    let title: String
    let views: Int
    let thumbnail: String
    let published_at: Date
    let start_date: String
    let end_date: String
}


