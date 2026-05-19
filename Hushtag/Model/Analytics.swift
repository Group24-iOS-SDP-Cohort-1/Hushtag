import Foundation

nonisolated struct AudienceMetrics: Codable {
    let views: Int
    let viewsChange: Float
    let likes: Int
    let likesChange: Float
    let estimatedMinutesWatched: Int
    let watchTimeChange: Float
    let subscribers: Int
    let subscribersChange: Float
}

enum AnalysisMetric {
    case views
    case likes
    case watchTime
    case subscribers
}

nonisolated struct LatestContent: Codable {
    let videoId: String
    let title: String
    let views: Int
    let likes: Int
    let thumbnail: String
    let publishedAt: Date
    let durationSeconds: Int
    let fetchedAt: String
}

nonisolated struct TopVideo: Codable {
    let videoId: String
    let title: String
    let views: Int
    let thumbnail: String
    let publishedAt: Date
    let startDate: String
    let endDate: String
}

nonisolated struct RevenueInsight: Codable {
    let estimatedAdRevenue: Double
    let grossRevenue: Double
    let yppRevenue: Double
}

enum RevenueType: String, Codable {
    case ads
    case paidContent
    case ypp
    case collaboration
}

nonisolated struct AudienceDemographic: Codable {
    let malePercentage: Double
    let femalePercentage: Double
    let topAgeGroup: String
    let subscribersGained: Int
    let subscribersLost: Int
}

nonisolated struct ViewerActivity: Codable, Identifiable {
    let id: UUID?
    let userId: UUID

    let day: Date
    let views: Int

    let startDate: Date?
    let endDate: Date?

    let fetchedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case day
        case views
        case startDate
        case endDate
        case fetchedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)

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
        if let startString = try container.decodeIfPresent(String.self, forKey: .startDate) {
            startDate = formatter.date(from: startString)
        } else {
            startDate = nil
        }

        // end_date
        if let endString = try container.decodeIfPresent(String.self, forKey: .endDate) {
            endDate = formatter.date(from: endString)
        } else {
            endDate = nil
        }

        fetchedAt = try container.decodeIfPresent(Date.self, forKey: .fetchedAt)
    }
}
