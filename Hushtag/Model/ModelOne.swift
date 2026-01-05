//
//  ModelOne.swift
//  Hushtag
//
//  Created by SDC-USER on 24/11/25.
//

import Foundation

struct TimeData: Codable{
    let hour: Int?
    let minute: Int?
}

struct DateData: Codable{
    let day: String?
    let date: String?
    let time: TimeData?
}

extension DateData {

    func toDate() -> Date? {
        guard
            let dateString = date,
            let timeData = time,
            let hour = timeData.hour,
            let minute = timeData.minute
        else {
            return nil
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]

        guard let baseDate = isoFormatter.date(from: dateString) else {
            return nil
        }

        return Calendar.current.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: baseDate
        )
    }
}

struct AnalysisDateData: Codable, Identifiable{
    let id = UUID()
    let day: String
    let date: String
    let time: TimeData
    let audienceEngagementRate: String
    
    enum CodingKeys: String, CodingKey {
        case day, date, time, audienceEngagementRate
    }
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

    enum CodingKeys: String, CodingKey {
        case id, trending, title, description, script, hashtag, videos, liked, tag, thumbnail
    }
}

struct Video: Codable {
    let id: String
    let url: String
    let videoTitle: String
    let views: String
    let link: String
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

struct Task: Codable, Identifiable {
    let id = UUID()
    let name: String
    let startDate: DateData
    let endDate: DateData
    let description: String
    let reminder: [String]
    var isCompleted : Bool

    enum CodingKeys: String, CodingKey {
        case name,startDate,endDate,description,reminder, isCompleted
    }
}

struct Post: Codable, Identifiable {
    let id = UUID()
    let name: String
    let postingTime: DateData
    let platform: [String]
    let description: String
    let reminder: [String]
    var isCompleted : Bool

    enum CodingKeys: String, CodingKey {
        case name,postingTime,platform,description,reminder, isCompleted
    }

    var platformType: [PlatformType]{
        switch platform.first{
        case "youtube": return [.youtube]
        case "instagram": return [.instagram]
        case "facebook": return [.facebook]
        default: return [.youtube]
        }
    }
}

struct Deal: Codable, Identifiable {
    let id = UUID()
    let name: String
    var deliverable: [Deliverable]
    let platform: [String]
    let phone: String
    let email: String
    let description: String
    let payment: Int
    let selectedIdeaIndex: String?

    enum CodingKeys: String, CodingKey {
        case name,deliverable,platform,phone,email,description,payment, selectedIdeaIndex
    }
}

struct Deliverable: Codable {
    let name: String
    let deadline: DateData
    var isCompleted : Bool
}


struct Analysis: Codable, Identifiable {
    let id: String
    let views: String
    let likes: String
    let incFollowers: String
    let followers: String
    let ageGroup: [String]
    let gender: [String: String]
    let post: Int
    let optimalTime: [AnalysisDateData]
    let engagementRate: String

    enum CodingKeys: String, CodingKey {
        case id,views,likes,incFollowers,followers,ageGroup,gender,optimalTime,engagementRate,post
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
    var contentPreferences: ContentPreferenceGroup = ContentPreferenceGroup()
}

struct PreferenceItem {
    let id: Int
    let title: String
    let subheading: String
    let options: [String]?
    let sections: [PreferenceSection]?
}

struct PreferenceGroup: Codable {
    var title: String = ""
    var subheading: String = ""
    var options: [String] = []
}

struct ContentPreferenceGroup: Codable {
    var title: String = ""
    var subheading: String = ""
    var sections: [PreferenceSection] = []
}

struct PreferenceSection: Codable {
    var title: String = ""
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
                options: pickYourNiche.options,
                sections: nil
            ),
            PreferenceItem(
                id: 2,
                title: setYourContentGoals.title,
                subheading: setYourContentGoals.subheading,
                options: setYourContentGoals.options,
                sections: nil
            ),
            PreferenceItem(
                id: 3,
                title: contentPreferences.title,
                subheading: contentPreferences.subheading,
                options: nil,
                sections: contentPreferences.sections
            )
        ]
    }
}

