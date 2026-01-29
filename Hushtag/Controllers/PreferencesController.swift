//
//  PreferencesController.swift
//  Hushtag
//
//  Created by Dhruav Mathur on 28/01/26.
//

import Foundation
import Supabase

final class PreferencesController {
    
    private let client = SupabaseConfig.client
    private let tableName = "user_preferences" // <--- ⚠️ REPLACE THIS
    
    func savePreferences(
        dict: [String: [String]],
        isYoutubeConnected: Bool
    ) async throws {
        
        // 1. Get Current User Session
        let session = try await client.auth.session
        
        // 2. Map Dictionary Keys to DB Columns
        // We use default empty arrays [] to prevent crashes if a key is missing
        let payload = PreferencePayload(
            user_id: session.user.id,
            niche: dict["Niche"] ?? [],
            content_goals: dict["Content Goals"] ?? [],
            content_length: dict["Content Length"] ?? [],
            content_type: dict["Content Tone"] ?? [], // Mapping "Tone" to "Type"
            youtube_connection: isYoutubeConnected
        )
        
        // 3. Send to Supabase
        // We don't need to return anything if we just want to save it.
        try await client.database
            .from(tableName)
            .insert(payload)
            .execute()
    }
}
