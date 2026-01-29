//
//  PreferencesModel.swift
//  Hushtag
//
//  Created by Dhruav Mathur on 28/01/26.
//

import Foundation

// MARK: - Insert Payload
// This struct matches your Supabase table columns exactly.
nonisolated struct PreferencePayload: Codable {
    let user_id: UUID
    let niche: [String]
    let content_goals: [String]
    let content_length: [String]
    let content_type: [String]      // Mapped from "Content Tone"
    let youtube_connection: Bool
}

// MARK: - Domain Model (Optional)
// Use this if you want to pass the data around your app cleanly
struct UserPreference {
    let id: Int64
    let niche: [String]
    let contentGoals: [String]
    let contentLength: [String]
    let contentType: [String]
    let isYoutubeConnected: Bool
}

// MARK: - Database Response (For fetching/decoding)
nonisolated struct PreferenceDB: Codable, Sendable {
    let id: Int64
    let user_id: UUID
    let created_at: Date
    let niche: [String]?
    let content_goals: [String]?
    let content_length: [String]?
    let content_type: [String]?
    let youtube_connection: Bool?
}
