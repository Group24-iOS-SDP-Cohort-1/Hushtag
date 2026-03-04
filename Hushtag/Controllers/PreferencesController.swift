import Foundation
import Supabase

final class PreferencesController {
    
    private let client = SupabaseConfig.client
    
    func savePreferences(
        dict: [String: [String]],
        isYoutubeConnected: Bool
    ) async throws {
        
        let session = try await client.auth.session
        
        let payload = PreferenceInsertPayload(
            id: session.user.id,
            niche: dict["Niche"] ?? [],
            content_goals: dict["Content Goals"] ?? [],
            content_length: dict["Content Length"] ?? [],
            content_type: dict["Content Tone"] ?? [],
            youtube_connection: isYoutubeConnected
        )
        
        try await client.database
            .from("user_preferences")
            .insert(payload)
            .execute()
    }
    
    func fetchPreferences() async throws -> UserPreference {
        let session = try await client.auth.session
        print("FETCH UID:", session.user.id)
        
        let preferences: [PreferenceDB] = try await client.database.from("user_preferences").select().eq("id", value: session.user.id)
            .execute()
            .value
        
        guard let latest = preferences.first else {
            throw NSError(domain: "No Preferences Found", code: 404)
        }
        
        return mapToPreference(latest)
    }
    
    private func mapToPreference(_ preference: PreferenceDB) -> UserPreference {
        UserPreference(
            id: preference.id,
            niche: preference.niche ?? [],
            contentGoals: preference.content_goals  ?? [],
            contentLength: preference.content_length ?? [],
            contentType: preference.content_type ?? [],
            isYoutubeConnected: preference.youtube_connection ?? false
        )
    }
}


