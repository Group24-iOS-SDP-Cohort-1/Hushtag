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
