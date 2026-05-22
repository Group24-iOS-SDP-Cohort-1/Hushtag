import Foundation
import Supabase

final class LikedIdeasController {
    private let client = SupabaseConfig.client

    func likeIdea(_ idea: Idea) async throws {
        let session = try await client.auth.session
        let stats = averageStats(from: idea.videos)

        let payload = LikedIdeaInsertPayload(
            id: UUID(),
            userId: session.user.id,
            ideaKey: idea.ideaKey ?? "",
            title: idea.title,
            description: idea.description,
            hashtags: idea.hashtags,
            views: stats.avgViews,
            likes: stats.avgLikes
        )

        try await client.database
            .from("liked_ideas")
            .insert(payload)
            .execute()
    }

    func unlikeIdea(ideaKey: String) async throws {
        let session = try await client.auth.session

        try await client.database
            .from("liked_ideas")
            .delete()
            .eq("userId", value: session.user.id)
            .eq("ideaKey", value: ideaKey)
            .execute()
    }

    func fetchLikedIdeas() async throws -> [Idea] {
        let session = try await client.auth.session

        let likedIdeasDB: [LikedIdeaDB] = try await client.database
            .from("liked_ideas")
            .select()
            .eq("userId", value: session.user.id)
            .execute()
            .value

        return likedIdeasDB.map { mapToIdea($0) }
    }

    private func mapToIdea(_ db: LikedIdeaDB) -> Idea {
        // If views/likes are stored (from search ideas), create a synthetic video
        // so the Performance Statistics section renders correctly.
        // Analytics ideas save with 0/0, so they remain videos: nil → stats hidden.
        let views = db.views ?? 0
        let likes = db.likes ?? 0
        let videos: [Video]? = (views > 0 || likes > 0)
            ? [Video(id: "avg", title: "Average", thumbnail: "", channel: "", views: views, likes: likes, comments: 0, publishedAt: "", link: nil)]
            : nil

        return Idea(
            id: UUID(),
            ideaKey: db.ideaKey,
            title: db.title,
            description: db.description ?? "",
            format: "",
            hashtags: db.hashtags ?? [],
            noveltyScore: 0,
            videos: videos,
            liked: true
        )
    }

    private func averageStats(from videos: [Video]?) -> (avgViews: Int, avgLikes: Int) {
        guard let videos = videos, !videos.isEmpty else {
            return (0, 0)
        }

        let totalViews = videos.reduce(0) { $0 + $1.views }
        let totalLikes = videos.reduce(0) { $0 + $1.likes }

        let avgViews = totalViews / videos.count
        let avgLikes = totalLikes / videos.count

        return (avgViews, avgLikes)
    }

    func attachConvoId(to ideaKey: String, convoId: UUID) async throws {
        let session = try await client.auth.session

        try await client.database
            .from("liked_ideas")
            .update([
                "convoId": convoId
            ])
            .eq("userId", value: session.user.id)
            .eq("ideaKey", value: ideaKey)
            .execute()
    }

    func fetchConvoId(for ideaKey: String) async throws -> UUID? {
        let session = try await client.auth.session

        let response: [ConvoResponse] = try await client.database
            .from("liked_ideas")
            .select("convoId")
            .eq("userId", value: session.user.id)
            .eq("ideaKey", value: ideaKey)
            .limit(1)
            .execute()
            .value

        return response.first?.convoId
    }
}
