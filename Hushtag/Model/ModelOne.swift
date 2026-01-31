//
//  ModelOne.swift
//  Hushtag
//
//  Created by SDC-USER on 24/11/25.
//

import Foundation

struct LikedIds {
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
    
    // MARK: - Public Helpers
    
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

struct Message {
    let text: String
    let isUser: Bool
    var markType: String? = nil
}

enum PlatformType:String{
    case youtube,instagram,facebook
}
//for idea
struct IdeaResponse: Codable {
    var ideas: [Idea] = []
    //var videos: [Video] = []
    
    init() {
        do {
            let response = try load()
            ideas = response.ideas
            //videos = response.videos
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getRandomIdea() -> Idea? {
        return ideas.randomElement()
    }
}

struct Idea: Codable, Identifiable {
    let id: String
    let trending: String
    let title: String
    let description: String
    let script: String
    let hashtag: [String]
    let videos: [Video]
    var liked: Bool
    let tag: String
    let thumbnail: String
    let engagementRate: Double
    
    enum CodingKeys: String, CodingKey {
        case id, trending, title, description, script, hashtag, videos, liked, tag, thumbnail, engagementRate
    }
}

struct Video: Codable {
    let id: String
    let url: String
    let videoTitle: String
    let views: String
    let link: String
    let engagementRate: [EngagementPoint]?
}

struct EngagementPoint: Codable {
    let date: Date
    let rate: Double
}

extension IdeaResponse {
    func load(from filename: String = "DataStorejson") throws -> IdeaResponse {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw NSError(
                domain: "IdeaResponse",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "DataSource.json not found"]
            )
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(IdeaResponse.self, from: data)
    }
    
    func decode(from data: Data) throws -> IdeaResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(IdeaResponse.self, from: data)
    }
    
    
}

//struct Task: Codable {
//    let name: String
//    let deadline: Date
//    var isCompleted : Bool
//}
//
//struct Post: Codable, Identifiable {
//    let id = UUID()
//    let name: String
//    let platform: [String]
//    var tasks: [Task]?
//    let reminder: [String]
//    
//    enum CodingKeys: String, CodingKey {
//        case name, platform, tasks, reminder
//    }
//    
//    var platformType: [PlatformType] {
//        platform.compactMap {
//            PlatformType(rawValue: $0.lowercased())
//        }
//    }
//    
//}

//struct Deal: Codable, Identifiable {
//    let id = UUID()
//    let name: String
//    var deliverable: [Deliverable]
//    let platform: [String]
//    let phone: String
//    let email: String
//    let description: String
//    let payment: Int
//    let selectedIdeaIndex: String?
//    
//    enum CodingKeys: String, CodingKey {
//        case name,deliverable,platform,phone,email,description,payment, selectedIdeaIndex
//    }
//}
//
//struct Deliverable: Codable {
//    let name: String
//    let deadline: Date
//    var isCompleted : Bool
//}
//
struct TopContentItem: Codable, Identifiable {
    let id: String
    let title: String
    let thumbnail: String   // asset name or URL
    let views: String
    let publishedTime: String
}

struct LatestContentPerformance: Codable {
    let title: String
    let thumbnail: String
    let publishedText: String   // e.g. "Published 2 days ago"
    let ranking: String         // "2 of 10"
    let views: String           // "42.1K"
    let avgDuration: String     // "5:24"
}

struct RevenueSource: Codable {
    let sf: String
    let name: String
    let amount: String
}

struct Analysis: Codable, Identifiable {
    let id: String
    
    // Audience metrics (NEW)
    let views: String
    let watchTime: String
    let subscribers: String
    let estRevenue: String
    
    // Change indicators (NEW)
    let viewsChange: String
    let watchTimeChange: String
    let subscribersChange: String
    let revenueChange: String
    let likes: String
    let incFollowers: String
    let followers: String
    let ageGroup: [String]
    let gender: [String: String]
    let post: Int
    let optimalTime: [AnalysisDateData]
    let engagementRate: String
    let topContent: [TopContentItem]
    let latestContent: LatestContentPerformance
    let revenueSource: [RevenueSource]
    
    enum CodingKeys: String, CodingKey {
        case id,
             views, watchTime, subscribers, estRevenue,
             viewsChange, watchTimeChange, subscribersChange, revenueChange,
             likes, incFollowers, followers,
             ageGroup, gender, post, optimalTime, engagementRate, topContent, latestContent, revenueSource
    }
}

extension Analysis {
    
    var audienceGrid: [(title: String, value: String, change: String)] {
        return [
            ("Views", views, viewsChange),
            ("Watch time", watchTime, watchTimeChange),
            ("Subscribers", subscribers, subscribersChange),
            ("Est. Revenue", estRevenue, revenueChange)
        ]
    }
}

struct AnalysisResponse: Codable {
    var analysis: [Analysis] = []
    
    init() {
        do {
            let response = try load()
            analysis = response.analysis
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension AnalysisResponse {
    
    func load(from filename: String = "DataStorejson") throws -> AnalysisResponse {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw NSError(
                domain: "AnalysisResponse",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "DataStore.json not found"]
            )
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(AnalysisResponse.self, from: data)
    }
    
    func decode(from data: Data) throws -> AnalysisResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(AnalysisResponse.self, from: data)
    }
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

//enum ScheduleItem {
//    case deal(Deal)
//    case post(Post)
//    
//    func date() -> Date? {
//        switch self {
//        case .deal(let deal):
//            return deal.deliverables.first?.deadline
//        case .post(let post):
//            return post.tasks?.first?.deadline
//        }
//    }
//    
//    var isCompleted: Bool {
//        switch self {
//        case .post(let post):
//            return post.tasks?.allSatisfy { $0.isCompleted } ?? false
//        case .deal(let deal):
//            return deal.deliverables.allSatisfy { $0.isCompleted }
//        }
//    }
//}
