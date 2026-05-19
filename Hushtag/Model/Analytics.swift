import Foundation

nonisolated struct AudienceMetrics: Codable {
    let views: Int
    let views_change: Float
    let likes: Int
    let likes_change: Float
    let estimated_minutes_watched: Int
    let watch_time_change: Float
    let subscribers: Int
    let subscribers_change: Float
}

enum AnalysisMetric {
    case views
    case likes
    case watchTime
    case subscribers
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

nonisolated struct ViewerActivity: Codable, Identifiable {
    let id: UUID?
    let user_id: UUID

    let day: Date
    let views: Int

    let start_date: Date?
    let end_date: Date?

    let fetched_at: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case day
        case views
        case start_date
        case end_date
        case fetched_at
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        user_id = try container.decode(UUID.self, forKey: .user_id)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        // day
        let dayString = try container.decode(String.self, forKey: .day)
        guard let parsedDay = formatter.date(from: dayString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .day,
                in: container,
                debugDescription: "Invalid date format: \(dayString)"
            )
        }
        day = parsedDay

        views = try container.decode(Int.self, forKey: .views)

        // start_date
        if let startString = try container.decodeIfPresent(String.self, forKey: .start_date) {
            start_date = formatter.date(from: startString)
        } else {
            start_date = nil
        }

        // end_date
        if let endString = try container.decodeIfPresent(String.self, forKey: .end_date) {
            end_date = formatter.date(from: endString)
        } else {
            end_date = nil
        }

        fetched_at = try container.decodeIfPresent(Date.self, forKey: .fetched_at)
    }
}
