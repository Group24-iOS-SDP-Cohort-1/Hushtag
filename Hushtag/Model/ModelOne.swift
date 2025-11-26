//
//  ModelOne.swift
//  Hushtag
//
//  Created by SDC-USER on 24/11/25.
//

import Foundation

struct TimeData: Codable{
    let hour: Int
    let minute: Int
}

struct DateData: Codable{
    let day: String
    let date: String
    let time: TimeData
}

enum PlatformType:String{
    case youtube,instagram,facebook
}
//for idea
struct IdeaResponse: Codable {
    var ideas: [Idea] = []
    var videos: [Video] = []

    init() {
        do {
            let response = try load()
            ideas = response.ideas
            videos = response.videos
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
    let videos: [String]
    let liked: Bool
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

// for tasks
struct TaskResponse: Codable {
    var tasks: [Task] = []
    init() {
        do {
            let response = try load()
            tasks = response.tasks
        } catch {
            print(error.localizedDescription)
        }
    }

    func getRandomIdea() -> Task? {
        return tasks.randomElement()
    }
}

struct Task: Codable, Identifiable {
    let id = UUID()
    let name: String
    let startDate: String
    let endDate: String
    let description: String
    let reminder: [String]

    enum CodingKeys: String, CodingKey {
        case name,startDate,endDate,description,reminder
    }
}

extension TaskResponse {
    func load(from filename: String = "DataStorejson") throws -> TaskResponse {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw NSError(
                domain: "TaskResponse",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "DataSource.json not found"]
            )
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(TaskResponse.self, from: data)
    }

    func decode(from data: Data) throws -> TaskResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(TaskResponse.self, from: data)
    }
}


// for Post
struct PostResponse: Codable {
    var posts: [Post] = []
    init() {
        do {
            let response = try load()
            posts = response.posts
        } catch {
            print(error.localizedDescription)
        }
    }

    func getRandomIdea() -> Post? {
        return posts.randomElement()
    }
}

struct Post: Codable, Identifiable {
    let id = UUID()
    let name: String
    let postingTime: DateData
    let platform: [String]
    let description: String
    let reminder: [String]

    enum CodingKeys: String, CodingKey {
        case name,postingTime,platform,description,reminder
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

extension PostResponse {
    func load(from filename: String = "DataStorejson") throws -> PostResponse {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw NSError(
                domain: "PostResponse",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "DataSource.json not found"]
            )
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(PostResponse.self, from: data)
    }

    func decode(from data: Data) throws -> PostResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(PostResponse.self, from: data)
    }
}


// for deals
struct DealResponse: Codable {
    var deals: [Deal] = []
    init() {
        do {
            let response = try load()
            deals = response.deals
        } catch {
            print(error.localizedDescription)
        }
    }

    func getRandomIdea() -> Deal? {
        return deals.randomElement()
    }
}

struct Deliverable: Codable {
    let name: String
    let deadline: DateData

}
struct Deal: Codable, Identifiable {
    let id = UUID()
    let name: String
    let deliverable: [Deliverable]
    let platform: [String]
    let phone: String
    let email: String
    let description: String
    let payment: Int
    let selectedIdea: String

    enum CodingKeys: String, CodingKey {
        case name,deliverable,platform,phone,email,description,payment,selectedIdea
    }
}


extension DealResponse {
    func load(from filename: String = "DataStorejson") throws -> DealResponse {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw NSError(
                domain: "PostResponse",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "DataSource.json not found"]
            )
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DealResponse.self, from: data)
    }

    func decode(from data: Data) throws -> DealResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(DealResponse.self, from: data)
    }
}

// for youtube analysis
struct youtubeResponse: Codable {
    var youtube: [Analysis] = []
    init() {
        do {
            let response = try load()
            youtube = response.youtube
        } catch {
            print(error.localizedDescription)
        }
    }

    func getRandomIdea() -> Analysis? {
        return youtube.randomElement()
    }
}

struct Analysis: Codable, Identifiable {
    let id = UUID()
    let views: String
    let likes: String
    let incFollowers: String
    let followers: String
    let ageGroup: [String]
    let gender: [String: String]
    let post: Int
    let optimalTime: [DateData]
    let engagementRate: String

    enum CodingKeys: String, CodingKey {
        case id,views,likes,incFollowers,followers,ageGroup,gender,optimalTime,engagementRate,post
    }
}

extension youtubeResponse {
    func load(from filename: String = "DataStorejson") throws -> youtubeResponse {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw NSError(
                domain: "youtubeResponse",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "DataSource.json not found"]
            )
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(youtubeResponse.self, from: data)
    }

    func decode(from data: Data) throws -> youtubeResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(youtubeResponse.self, from: data)
    }
}

// for instagram analysis
struct instagramResponse: Codable {
    var instagram: [Analysis] = []
    init() {
        do {
            let response = try load()
            instagram = response.instagram
        } catch {
            print(error.localizedDescription)
        }
    }

    func getRandomIdea() -> Analysis? {
        return instagram.randomElement()
    }
}

extension instagramResponse {
    func load(from filename: String = "DataStorejson") throws -> instagramResponse {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw NSError(
                domain: "instagramResponse",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "DataSource.json not found"]
            )
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(instagramResponse.self, from: data)
    }

    func decode(from data: Data) throws -> instagramResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(instagramResponse.self, from: data)
    }
}

// for facebook analysis
struct facebookResponse: Codable {
    var facebook: [Analysis] = []
    init() {
        do {
            let response = try load()
            facebook = response.facebook
        } catch {
            print(error.localizedDescription)
        }
    }

    func getRandomIdea() -> Analysis? {
        return facebook.randomElement()
    }
}

extension facebookResponse {
    func load(from filename: String = "DataStorejson") throws -> facebookResponse {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw NSError(
                domain: "facebookResponse",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "DataSource.json not found"]
            )
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(facebookResponse.self, from: data)
    }

    func decode(from data: Data) throws -> facebookResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(facebookResponse.self, from: data)
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

