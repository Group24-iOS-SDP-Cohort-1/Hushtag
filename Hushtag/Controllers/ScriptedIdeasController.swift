//
//  ScriptedIdeasController.swift
//  Hushtag
//
//  Created by SDC-USER on 03/02/26.
//

import Foundation
import Supabase

final class ScriptedIdeasController {
    
    // Use your shared configuration
    private let client = SupabaseConfig.client
    
    // MARK: - Create (Insert new script)
    func addScript(scriptContent: String) async throws -> ScriptedIdea {
        // 1. Get Current User
        let session = try await client.auth.session
        
        // 2. Prepare Payload
        let payload = ScriptedIdeaInsertPayload(
            user_id: session.user.id,
            title: nil,         // Initially empty
            description: nil,   // Initially empty
            script: scriptContent,
            thumbnail: nil      // Initially empty
        )
        
        // 3. Insert into Supabase
        let ideaDB: ScriptedIdeaDB = try await client.database
            .from("scripted_ideas") // Make sure this matches your table name
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
        
        return mapToIdea(ideaDB)
    }
    
    // MARK: - Read (Fetch all scripts for user)
    func fetchScripts() async throws -> [ScriptedIdea] {
        let session = try await client.auth.session
        
        let ideasDB: [ScriptedIdeaDB] = try await client.database
            .from("scripted_ideas")
            .select()
            .eq("user_id", value: session.user.id) // RLS Policy safety net
            .order("created_at", ascending: false) // Newest first
            .execute()
            .value
        
        return ideasDB.map { mapToIdea($0) }
    }
    
    // MARK: - Update (Update Title, Desc, Thumbnail, or Script)
    func updateScript(_ idea: ScriptedIdea) async throws -> ScriptedIdea {
        
        // We only send the fields we want to update
        let payload = ScriptedIdeaUpdatePayload(
            title: idea.title,
            description: idea.description,
            script: idea.script,
            thumbnail: idea.thumbnailURL
        )
        
        let updatedDB: ScriptedIdeaDB = try await client.database
            .from("scripted_ideas")
            .update(payload)
            .eq("id", value: idea.id)
            .select()
            .single()
            .execute()
            .value
            
        return mapToIdea(updatedDB)
    }
    
    // MARK: - Delete
    func deleteScript(_ id: UUID) async throws {
        let session = try await client.auth.session
        
        try await client.database
            .from("scripted_ideas")
            .delete()
            .eq("id", value: id)
            .eq("user_id", value: session.user.id) // Double security check
            .execute()
    }
    
    // MARK: - Helper Mapper
    private func mapToIdea(_ db: ScriptedIdeaDB) -> ScriptedIdea {
        return ScriptedIdea(
            id: db.id,
            title: db.title,
            description: db.description,
            script: db.script,
            thumbnailURL: db.thumbnail,
            createdAt: db.created_at
        )
    }
}
