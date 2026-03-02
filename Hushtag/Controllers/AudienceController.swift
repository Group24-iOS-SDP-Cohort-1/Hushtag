import Foundation
import Supabase

final class AudienceController {

    private let client = SupabaseConfig.client
    
    func fetchData() async throws -> [AudienceMetrics] {
        let session = try await client.auth.session
        
        let data: [AudienceMetrics] = try await client.database
            .from("audience")
            .select()
            .eq("user_id", value: session.user.id)
            .execute()
            .value
        
        return data
    }
}
