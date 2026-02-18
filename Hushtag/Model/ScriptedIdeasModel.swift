//
//  ScriptedIdeas.swift
//  Hushtag
//
//  Created by SDC-USER on 03/02/26.
//

import Foundation

// 1. The UI Model
struct ScriptedIdea: Identifiable, Sendable {
    let id: UUID
    var title: String?
    var description: String?
    var script: String?
    var thumbnailURL: String?
    var tags: [String]? // Keeping UI name as 'tags' for consistency, mapped from 'hashtags'
    var mockTitle: String?
    var mockDescription: String?
    let createdAt: Date
}

// 2. The Database Model
nonisolated struct ScriptedIdeaDB: Codable, Sendable {
    let id: UUID
    let user_id: UUID
    let title: String?
    let description: String?
    let script: String?
    let thumbnail: String?
    let hashtags: [String]? // <--- UPDATED: Matches DB schema 'hashtags'
    let mock_title: String?
    let mock_description: String?
    let created_at: Date?
}

// 3. The Insert Payload
nonisolated struct ScriptedIdeaInsertPayload: Encodable, Sendable {
    let user_id: UUID
    let title: String?
    let description: String?
    let script: String?
    let thumbnail: String?
    let hashtags: [String]? // <--- UPDATED
    let mock_title: String?
    let mock_description: String?
}

// 4. The Update Payload
nonisolated struct ScriptedIdeaUpdatePayload: Encodable, Sendable {
    let title: String?
    let description: String?
    let script: String?
    let thumbnail: String?
    let hashtags: [String]? // <--- UPDATED
    let mock_title: String?
    let mock_description: String?
    
    enum CodingKeys: String, CodingKey {
        case title, description, script, thumbnail, hashtags, mock_title, mock_description // <--- UPDATED
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // .encode(...) will write 'null' into the JSON if the value is nil
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(script, forKey: .script)
        try container.encode(thumbnail, forKey: .thumbnail)
        try container.encode(hashtags, forKey: .hashtags) // <--- UPDATED
        try container.encode(mock_title, forKey: .mock_title)
        try container.encode(mock_description, forKey: .mock_description)
    }
}
