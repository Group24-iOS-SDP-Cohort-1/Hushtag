import Foundation
import Supabase

final class LikedIdeasController {
    
    private let client = SupabaseConfig.client
    
    func likeIdea(_ idea: Idea) async throws {
        
        let session = try await client.auth.session
        let stats = averageStats(from: idea.videos)
        
        let payload = LikedIdeaInsertPayload(
            id: UUID(),
            user_id: session.user.id,
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
            .eq("user_id", value: session.user.id)
            .eq("ideaKey", value: ideaKey)
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
            id: UUID(),
            ideaKey: db.ideaKey,      
            title: db.title,
            description: db.description ?? "",
            format: "",
            hashtags: db.hashtags ?? [],
            noveltyScore: 0,
            videos: nil,
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
                "convo_id": convoId.uuidString
            ])
            .eq("user_id", value: session.user.id)
            .eq("ideaKey", value: ideaKey)
            .execute()
    }
}
