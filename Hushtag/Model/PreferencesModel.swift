//
//  PreferencesModel.swift
//  Hushtag
//
//  Created by Dhruav Mathur on 28/01/26.
//

import Foundation

nonisolated struct PreferenceInsertPayload: Codable {
    let user_id: UUID
    let niche: [String]
    let content_goals: [String]
    let content_length: [String]
    let content_type: [String]
    let youtube_connection: Bool
}

struct UserPreference {
    let id: UUID
    let niche: [Niche]
    let contentGoals: [ContentGoal]
    let contentLength: [ContentLength]
    let contentType: [ContentType]
    let isYoutubeConnected: Bool
}

nonisolated struct PreferenceDB: Codable, Sendable {
    let id: UUID
    let user_id: UUID
    let created_at: Date
    let niche: [Niche]?
    let content_goals: [ContentGoal]?
    let content_length: [ContentLength]?
    let content_type: [ContentType]?
    let youtube_connection: Bool?
}


enum Niche: String, Codable, CustomStringConvertible {
    case beauty
    case lifestyle
    case fashion
    case skincare
    case food
    case wellness
    case music
    case game
    case education
    case finance
    case dance
    case others
    var description: String {
        rawValue
    }
}

enum ContentType: String, Codable, CustomStringConvertible {
    case funny
    case relatable
    case casual
    case aesthetic
    case trendy
    case motivational
    case lowkey
    case sciFi = "sci-fi"
    case other
    
    var description: String {
        rawValue
    }
}

enum ContentLength: String, Codable, CustomStringConvertible {
    case shortForm = "short-form"
    case longForm = "long-form"
    var description: String {
        rawValue
    }
}

enum ContentGoal: String, Codable, CustomStringConvertible {
    case growth
    case engagement
    case retention
    case conversion
    case branding
    var description: String {
        rawValue
    }
}
