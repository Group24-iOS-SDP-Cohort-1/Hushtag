//
//  ModelOne.swift
//  Hushtag
//
//  Created by SDC-USER on 24/11/25.
//

import Foundation

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
    let id: String
    let name: String
    let startDate: String
    let endDate: String
    let description: String
    let reminder: [String]

    enum CodingKeys: String, CodingKey {
        case id,name,startDate,endDate,description,reminder
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
   let id: String
   let name: String
   let postingTime: String
   let platform: String
   let description: String
   let reminder: [String]


    enum CodingKeys: String, CodingKey {
        case id,name,postingTime,platform,description,reminder
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

struct Deal: Codable, Identifiable {
    let id: String
    let name: String
    let deliverable: String
    let platform: String
    let phone: String
    let email: String
    let description: String
    let payment: Int
    let selectedIdea: String


    enum CodingKeys: String, CodingKey {
        case id,name,deliverable,platform,phone,email,description,payment,selectedIdea
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
