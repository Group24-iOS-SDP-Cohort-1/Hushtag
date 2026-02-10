//
//  ChatHistory.swift
//  Hushtag
//
//  Created by SDC-USER on 04/02/26.
//

import Foundation

// 1. Database Model (Reading data)
nonisolated struct ChatMessageDB: Codable, Sendable {
    let id: UUID
    let idea_id: UUID
    let is_user: Bool
    let text_content: String
    let created_at: Date
}

// 2. Insert Payload (Writing data)
nonisolated struct ChatMessageInsertPayload: Encodable, Sendable {
    let idea_id: UUID
    let user_id: UUID
    let is_user: Bool
    let text_content: String
    let created_at: Date
}
