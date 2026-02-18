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
            hashtags: nil, // <--- Initialize with empty array
            mock_title: nil,        // <--- Start empty
            mock_description: nil   // <--- Start empty
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
            hashtags: idea.tags, // <--- Pass the tags to hashtags
            mock_title: idea.mockTitle,             // <--- Save Mock Title
            mock_description: idea.mockDescription  // <--- Save Mock Desc
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
            tags: db.hashtags ?? [], // <--- Map DB hashtags to UI tags
            mockTitle: db.mock_title,             // <--- Map it
            mockDescription: db.mock_description, // <--- Map it
            createdAt: db.created_at ?? Date()
        )
    }
    
    
    
    
    
    
    
    // MARK: - CHAT HISTORY
    
    
    func batchSaveMessages(ideaID: UUID, messages: [Message]) async throws {
            let session = try await client.auth.session
            
            // Convert your UI messages to Database Payloads
        let payloads = messages.enumerated().map { (index, msg) in
            
            // 2. Logic: Create a timestamp based on the index.
            // If we have 10 messages, the last one (index 9) is 'Now'.
            // The one before it (index 8) is 'Now - 1 second', etc.
            // This ensures strict chronological order in the database.
            let secondsAgo = Double(messages.count - 1 - index)
            let uniqueDate = Date().addingTimeInterval(-secondsAgo)
            
            return ChatMessageInsertPayload(
                idea_id: ideaID,
                user_id: session.user.id,
                is_user: msg.isUser,
                text_content: msg.text,
                created_at: uniqueDate // <--- Sending our calculated time
            )
        }
            
            // Insert all at once
        try await client.database
            .from("chat_history")
            .insert(payloads)
            .execute()
        }
    
    func saveChatMessage(ideaID: UUID, text: String, isUser: Bool) async throws {
            let session = try await client.auth.session
            
            let payload = ChatMessageInsertPayload(
                idea_id: ideaID,
                user_id: session.user.id,
                is_user: isUser,
                text_content: text,
                created_at: Date()
            )
            
            try await client.database
                .from("chat_history")
                .insert(payload)
                .execute()
        }
    
    
    
    func fetchChatHistory(for ideaID: UUID) async throws -> [Message] {
            let rows: [ChatMessageDB] = try await client.database
                .from("chat_history")
                .select()
                .eq("idea_id", value: ideaID)
                .order("created_at", ascending: true) // Oldest first
                .execute()
                .value
            
            // Convert DB format back to UI format
            return rows.map { row in
                Message(text: row.text_content, isUser: row.is_user)
            }
        }
}
