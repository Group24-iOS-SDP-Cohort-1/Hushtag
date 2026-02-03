//
//  ScriptedIdeas.swift
//  Hushtag
//
//  Created by SDC-USER on 03/02/26.
//

import Foundation

// 1. The UI Model (Used in your SwiftUI Views)
struct ScriptedIdea: Identifiable, Sendable {
    let id: UUID
    var title: String?
    var description: String?
    var script: String? // Maps to 'script' column
    var thumbnailURL: String? // Maps to 'thumbnail' column
    let createdAt: Date
}

// 2. The Database Model (Matches your Supabase Table columns EXACTLY)
nonisolated struct ScriptedIdeaDB: Codable, Sendable {
    let id: UUID
    let user_id: UUID
    let title: String?
    let description: String?
    let script: String?      // matches column 'script'
    let thumbnail: String?   // matches column 'thumbnail'
    let created_at: Date
}

// 3. The Insert Payload (What we send when creating a new row)
nonisolated struct ScriptedIdeaInsertPayload: Encodable, Sendable {
    let user_id: UUID
    let title: String?
    let description: String?
    let script: String?
    let thumbnail: String?
}

// 4. The Update Payload (For updating specific fields)
nonisolated struct ScriptedIdeaUpdatePayload: Encodable, Sendable {
    let title: String?
    let description: String?
    let script: String?
    let thumbnail: String?
    
    
    enum CodingKeys: String, CodingKey {
            case title, description, script, thumbnail
        }
    
    
    func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // .encode(...) will write 'null' into the JSON if the value is nil
            try container.encode(title, forKey: .title)
            try container.encode(description, forKey: .description)
            try container.encode(script, forKey: .script)
            try container.encode(thumbnail, forKey: .thumbnail)
        }
}
