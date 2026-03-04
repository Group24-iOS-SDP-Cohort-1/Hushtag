//
//  ModelOne.swift
//  Hushtag
//
//  Created by SDC-USER on 24/11/25.
//

import Foundation
import CryptoKit

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


struct LikedIds {
    static var likedIdeaIds: Set<String> = []
}


//struct YouTubeAuthPayload: Encodable {
//    let user_id: String
//    let auth_code: String
//}

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
        formatter.dateFormat = "h:mm a"   // Example: 4:30 PM
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
        case 0..<1_000:
            return "\(self)"

        case 1_000..<1_000_000:
            return String(format: "%.1fK", num / 1_000)
                .replacingOccurrences(of: ".0", with: "")

        case 1_000_000..<1_000_000_000:
            return String(format: "%.1fM", num / 1_000_000)
                .replacingOccurrences(of: ".0", with: "")

        default:
            return String(format: "%.1fB", num / 1_000_000_000)
                .replacingOccurrences(of: ".0", with: "")
        }
    }
}


struct AnalysisDateData: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let audienceEngagementRate: String
}

struct TimePayload: Codable {
    let hour: Int
    let minute: Int
}

enum PlatformType:String{
    case youtube,instagram,facebook
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

// preference
struct PreferenceResponse: Codable {
    var preferences: Preferences = Preferences()
    init() {
        do {
            let response = try load()
            preferences = response.preferences
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct Preferences: Codable {
    var pickYourNiche: PreferenceGroup = PreferenceGroup()
    var setYourContentGoals: PreferenceGroup = PreferenceGroup()
    var contentPreferences: PreferenceGroup = PreferenceGroup()
    var connectAccount: PreferenceGroup = PreferenceGroup()
}

struct PreferenceItem {
    let id: Int
    let title: String
    let subheading: String
    let sections: [PreferenceSection]
}

struct PreferenceGroup: Codable {
    var title: String = ""
    var subheading: String = ""
    var sections: [PreferenceSection] = []
}

struct PreferenceSection: Codable {
    var title: String = ""
    var hasTextInput: Bool = false
    var options: [String] = []
}

extension PreferenceResponse {
    func load(from filename: String = "DataStorejson") throws -> PreferenceResponse {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw NSError(
                domain: "PreferenceResponse",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "DataSource.json not found"]
            )
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(PreferenceResponse.self, from: data)
    }
    func decode(from data: Data) throws -> PreferenceResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(PreferenceResponse.self, from: data)
    }
}

extension Preferences {
    func toPreferenceItems() -> [PreferenceItem] {
        return [
            PreferenceItem(
                id: 1,
                title: pickYourNiche.title,
                subheading: pickYourNiche.subheading,
                //options: pickYourNiche.options,
                sections: pickYourNiche.sections
            ),
            PreferenceItem(
                id: 2,
                title: setYourContentGoals.title,
                subheading: setYourContentGoals.subheading,
                //options: setYourContentGoals.options,
                sections: setYourContentGoals.sections
            ),
            PreferenceItem(
                id: 3,
                title: contentPreferences.title,
                subheading: contentPreferences.subheading,
                //options: nil,
                sections: contentPreferences.sections
            ),
            PreferenceItem(
                id: 4,
                title: connectAccount.title,
                subheading: connectAccount.subheading,
                //options: nil,
                sections: connectAccount.sections
            )
        ]
    }
}
