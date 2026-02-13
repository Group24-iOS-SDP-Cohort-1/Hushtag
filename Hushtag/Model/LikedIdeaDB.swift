//
//  LikedIdeaDB.swift
//  Hushtag
//
//  Created by SDC-USER on 12/02/26.
//
//

import Foundation

nonisolated struct LikedIdeaDB: Codable {
    let id: UUID
    let user_id: UUID
    let title: String
    let description: String?
    let hashtags: [String]?
}

nonisolated struct LikedIdeaInsertPayload: Codable {
    let id: UUID
    let user_id: UUID
    let title: String
    let description: String?
    let hashtags: [String]?
}
