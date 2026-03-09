import Foundation
import Supabase

final class ProfileController {
    
    private let client = SupabaseConfig.client
    
    func fetchProfile() async throws -> Profile {
        let session = try await client.auth.session
        
        let profileDB: ProfileDB = try await client.database
            .from("profiles")
            .select()
            .eq("user_id", value: session.user.id)
            .single()
            .execute()
            .value
        
        return mapToProfile(profileDB)
    }
    
    func updateProfile(
        fullName: String,
        avatarURL: String?
    ) async throws -> Profile {
        
        let session = try await client.auth.session
        
        let payload = ProfileUpdatePayload(
            full_name: fullName,
            avatar_url: avatarURL
        )
        
        let updated: [ProfileDB] = try await client.database
            .from("profiles")
            .update(payload)
            .eq("user_id", value: session.user.id)
            .select()
            .execute()
            .value
        
        guard let profile = updated.first else {
            throw NSError(domain: "ProfileUpdate", code: 0)
        }
        
        return mapToProfile(profile)
    }
    
    
    private func mapToProfile(_ db: ProfileDB) -> Profile {
        Profile(
            id: db.user_id,
            fullName: db.full_name,
            email: db.email,
            avatarURL: db.avatar_url,
            isYouTubeConnected: db.is_youtube_connected ?? false
        )
    }
}
