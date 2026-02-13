//
//  LikedIdeasController.swift
//  Hushtag
//
//  Created by SDC-USER on 12/02/26.
//

import Foundation
import Supabase

final class LikedIdeasController {

    private let client = SupabaseConfig.client

    func likeIdea(_ idea: Idea) async throws {

        let session = try await client.auth.session
        print("LIKING AS USER:", session.user.id)
        let payload = LikedIdeaInsertPayload(
            id: UUID(),
            user_id: session.user.id,
            title: idea.title,
            description: idea.description,
            hashtags: idea.hashtags
        )

        try await client.database
            .from("liked_ideas")
            .insert(payload)
            .execute()
    }

    func unlikeIdea(title: String) async throws {

        let session = try await client.auth.session

        try await client.database
            .from("liked_ideas")
            .delete()
            .eq("user_id", value: session.user.id)
            .eq("title", value: title)
            .execute()
    }


    func fetchLikedIdeas() async throws -> [Idea] {

        let session = try await client.auth.session

        let likedIdeasDB: [LikedIdeaDB] = try await client.database
            .from("liked_ideas")
            .select()
            .eq("user_id", value: session.user.id)
            .execute()
            .value

        return likedIdeasDB.map { mapToIdea($0) }
    }

    private func mapToIdea(_ db: LikedIdeaDB) -> Idea {
        Idea(
            id: db.id,
            title: db.title,
            description: db.description ?? "",
            format: "",
            hashtags: db.hashtags ?? [],
            noveltyScore: 0,
            videos: nil,
            liked: true
        )
    }
}
