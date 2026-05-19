import CryptoKit
import Foundation

func makeIdeaKey(
    title: String,
    description: String,
    format: String,
    hashtags: [String]
) -> String {
    let raw = "\(title.lowercased())|\(description.lowercased())|\(format)|\(hashtags.sorted().joined())"
    let hash = SHA256.hash(data: Data(raw.utf8))
    return hash.map { String(format: "%02x", $0) }.joined()
}

enum LikedIds {
    static var likedIdeaIds: Set<String> = []
}

extension Date {
    private static let dayOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = .current
        return formatter
    }()

    private static let dateAndMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        formatter.locale = .current
        return formatter
    }()

    private static let dayDateYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd MMM yyyy"
        formatter.locale = .current
        return formatter
    }()

    private static let deadlineFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        formatter.locale = .current
        return formatter
    }()

    private static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = .current
        return formatter
    }()

    private static let timeOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // Example: 4:30 PM
        formatter.locale = .current
        return formatter
    }()

    func dayOnly() -> String {
        Self.dayOnlyFormatter.string(from: self)
    }

    func dateAndMonth() -> String {
        Self.dateAndMonthFormatter.string(from: self)
    }

    func dayDateYear() -> String {
        Self.dayDateYearFormatter.string(from: self)
    }

    func deadlineFormatted() -> String {
        Self.deadlineFormatter.string(from: self)
    }

    func monthAndYear() -> String {
        Self.monthYearFormatter.string(from: self)
    }

    func timeOnly() -> String {
        Self.timeOnlyFormatter.string(from: self)
    }
}

extension Int {
    func formattedCount() -> String {
        let num = Double(self)

        switch num {
        case 0 ..< 1000:
            return "\(self)"

        case 1000 ..< 1_000_000:
            return String(format: "%.1fK", num / 1000)
                .replacingOccurrences(of: ".0", with: "")

        case 1_000_000 ..< 1_000_000_000:
            return String(format: "%.1fM", num / 1_000_000)
                .replacingOccurrences(of: ".0", with: "")

        default:
            return String(format: "%.1fB", num / 1_000_000_000)
                .replacingOccurrences(of: ".0", with: "")
        }
    }
}

nonisolated struct ClusterIdeaAPIResponse: Codable {
    let mode: String
    let ideaLimit: Int?
    let results: [ClusterIdea]
}

struct ClusterIdea: Codable {
    let theme: String
    let gaps: [String]
    let format: String
    let idea: Idea
}

struct Idea: Codable, Identifiable {
    let id: UUID
    let ideaKey: String?
    let title: String
    let description: String
    let format: String
    let hashtags: [String]
    let noveltyScore: Int
    let videos: [Video]?
    var expandedDescription: String?
    var liked: Bool?
}

struct Video: Codable, Identifiable {
    let id: String
    let title: String
    let thumbnail: String
    let channel: String
    let views: Int
    let likes: Int
    let comments: Int
    let publishedAt: String
    let link: String?
}
