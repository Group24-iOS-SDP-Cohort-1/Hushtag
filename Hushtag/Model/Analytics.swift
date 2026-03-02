import Foundation

nonisolated struct AudienceMetrics: Codable {
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

nonisolated struct LatestContent: Codable {
    let video_id: String
    let title: String
    let views: Int
    let likes: Int
    let thumbnail: String
    let published_at: Date
    let duration_seconds: Int
    let fetched_at: String
}

nonisolated struct TopVideo: Codable {
    let video_id: String
    let title: String
    let views: Int
    let thumbnail: String
    let published_at: Date
    let start_date: String
    let end_date: String
}

nonisolated struct RevenueInsight: Codable {

    let estimated_ad_revenue: Double
    let gross_revenue: Double
    let ypp_revenue: Double
}

enum RevenueType: String, Codable {
    case ads
    case paidContent
    case ypp
    case collaboration
}

nonisolated struct AudienceDemographic: Codable {
    let male_percentage: Double
    let female_percentage: Double
    let top_age_group: String
    let subscribers_gained: Int
    let subscribers_lost: Int
}
