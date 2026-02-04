//
//  ScriptedIdeasController.swift
//  Hushtag
//
//  Created by SDC-USER on 03/02/26.
//

import Foundation
import Supabase

final class ScriptedIdeasController {
    
    private let client = SupabaseConfig.client
    
    // MARK: - Create (Insert new script)
    func addScript(scriptContent: String) async throws -> ScriptedIdea {
        let session = try await client.auth.session
        
        let payload = ScriptedIdeaInsertPayload(
            user_id: session.user.id,
            title: nil,
            description: nil,
            script: scriptContent,
            thumbnail: nil,
            tags: [] // <--- Initialize with empty array
        )
        
        let ideaDB: ScriptedIdeaDB = try await client.database
            .from("scripted_ideas")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
        
        return mapToIdea(ideaDB)
    }
    
    // MARK: - Read (Fetch all scripts)
    func fetchScripts() async throws -> [ScriptedIdea] {
        let session = try await client.auth.session
        
        let ideasDB: [ScriptedIdeaDB] = try await client.database
            .from("scripted_ideas")
            .select()
            .eq("user_id", value: session.user.id)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return ideasDB.map { mapToIdea($0) }
    }
    
    // MARK: - Update
    func updateScript(_ idea: ScriptedIdea) async throws -> ScriptedIdea {
        
        // Pass the tags from the UI model into the update payload
        let payload = ScriptedIdeaUpdatePayload(
            title: idea.title,
            description: idea.description,
            script: idea.script,
            thumbnail: idea.thumbnailURL,
            tags: idea.tags // <--- Pass the tags here
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
            .eq("user_id", value: session.user.id)
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
            tags: db.tags ?? [], // <--- Map DB tags (safely unwrapped to empty array)
            createdAt: db.created_at
        )
    }
}
