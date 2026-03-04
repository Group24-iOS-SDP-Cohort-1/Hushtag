import Foundation
import Supabase

final class AudienceController {
    
    private let client = SupabaseConfig.client
    
    func fetchAudienceMetrics() async throws -> [AudienceMetrics] {
        let session = try await client.auth.session
        
        let data: [AudienceMetrics] = try await client.database
            .from("audience")
            .select()
            .eq("user_id", value: session.user.id)
            .execute()
            .value
        
        return data
    }
    
    func fetchTopVideos() async throws -> [TopVideo] {
        let session = try await client.auth.session
        
        let data: [TopVideo] = try await client.database
            .from("top_videos")
            .select()
            .eq("user_id", value: session.user.id)
            .execute()
            .value
        
        return data
    }
    
    func fetchLatestContent() async throws -> [LatestContent] {
        let session = try await client.auth.session
        
        let data: [LatestContent] = try await client.database
            .from("latest_content")
            .select()
            .eq("user_id", value: session.user.id)
            .execute()
            .value
        
        return data
    }
    
    func fetchRevenueInsight() async throws -> [RevenueInsight] {
        let session = try await client.auth.session
        
        let data: [RevenueInsight] = try await client.database
            .from("revenue_insights")
            .select()
            .eq("user_id", value: session.user.id)
            .execute()
            .value
        
        return data
    }
    
    func fetchAudienceDemographic() async throws -> [AudienceDemographic] {
        let session = try await client.auth.session
        
        let data: [AudienceDemographic] = try await client.database
            .from("audience_demographics")
            .select()
            .eq("user_id", value: session.user.id)
            .execute()
            .value
        
        return data
    }
    
    func fetchViewerActivity() async throws -> [ViewerActivity] {
        
        let session = try await client.auth.session
        
        let data: [ViewerActivity] = try await client.database
            .from("viewer_activity")
            .select()
            .eq("user_id", value: session.user.id)
            .order("day", ascending: true)
            .execute()
            .value
        
        return data
    }
}
