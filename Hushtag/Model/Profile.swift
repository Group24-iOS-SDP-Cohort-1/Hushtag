//
//  Profile.swift
//  Hushtag
//
//  Created by SDC-USER on 31/01/26.
//

import Foundation

// MARK: - UI Model
struct Profile: Identifiable, Sendable {
    let id: UUID
    var fullName: String
    var email: String
    var avatarURL: String?
}

// MARK: - DB Model
nonisolated struct ProfileDB: Codable, Sendable {
    let id: UUID
    let full_name: String
    let email: String
    let avatar_url: String?
    let created_at: Date
    let updated_at: Date
}

// MARK: - Insert Payload (rarely used because of trigger)
nonisolated struct ProfileInsertPayload: Encodable, Sendable {
    let id: UUID
    let full_name: String
    let email: String
    let avatar_url: String?
}

// MARK: - Update Payload
nonisolated struct ProfileUpdatePayload: Encodable, Sendable {
    let full_name: String
    let avatar_url: String?
}
