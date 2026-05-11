import Foundation
import Supabase

final class ScriptedIdeasController {
    
    private let client = SupabaseConfig.client
    
    func addChatMessage(id: UUID, sender: Role, content: String) async throws -> ChatMessageDB {
        
        let payload = ChatMessageInsertPayload(
            conversation_id: id,
            role: sender,
            content: content
        )
        
        let result: ChatMessageDB = try await client.database
            .from("chat_history")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
        
        return result
    }
    
    func addConversation(id: UUID, ideaId: UUID? = nil) async throws -> Conversation {
        let session = try await client.auth.session
        
        let payload = ConversationInsertPayload(
            id: id,
            user_id: session.user.id,
            idea_id: ideaId
        )
        
        let result: Conversation = try await client.database
            .from("conversations")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
        
        return result
    }
    
    func getBotMessage() async throws -> ChatMessageDB {
        let chats: ChatMessageDB = try await client.database.from("chat_history").select().eq("role", value: "bot").execute().value
        
        return chats
    }
    
    func fetchConversations() async throws -> [Conversation] {
        let session = try await client.auth.session
        
        let result: [Conversation] = try await client.database
            .from("conversations")
            .select("""
                    id,
                    user_id,
                    title,
                    created_at,
                idea_id,
                    chat_history!inner(conversation_id),
                    scripted_ideas (
                        id,
                        chat_id,
                        title,
                        description,
                        script,
                        thumbnail
                    )
                """)
            .eq("user_id", value: session.user.id.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return result
    }
    
    func fetchConversation(for ideaId: UUID) async throws -> Conversation? {
        let result: [Conversation] = try await client.database
            .from("conversations")
            .select("""
                id,
                user_id,
                title,
                created_at,
                scripted_ideas (
                    id,
                    chat_id,
                    title,
                    description,
                    script,
                    thumbnail
                )
            """)
            .eq("idea_id", value: ideaId.uuidString)
            .limit(1)
            .execute()
            .value
        
        return result.first
    }
    
    
    func updateScript() {
        
    }
    
    func deleteScript(id: UUID) async throws {
        
        try await client.database
            .from("scripted_ideas")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    func addScript(_ script: ScriptedIdea) async throws -> ScriptedIdeaDB{
        let session = try await client.auth.session
        
        let payload = ScriptedIdeaInsertPayload(
            user_id: session.user.id,
            chat_id: script.chat_id,
            title: script.title,
            description: script.description,
            script: script.script,
            thumbnail: script.thumbnail,
            hashtags: script.tags,
        )
        
        let result: ScriptedIdeaDB = try await client.database
            .from("scripted_ideas")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
        
        return result
    }
    
    func fetchScript() async throws -> [ScriptedIdea] {
        let chats: [ScriptedIdea] = try await client.database.from("scripted_ideas").select().execute().value
        
        return chats
    }
    func fetchMessages(for conversationID: UUID) async throws -> [ChatMessageDB] {
        
        let result: [ChatMessageDB] = try await client.database
            .from("chat_history")
            .select()
            .eq("conversation_id", value: conversationID.uuidString)
            .order("created_at", ascending: true)
            .execute()
            .value
        
        return result
    }
    
    /// Fetches specific scripted ideas by their IDs.
    func fetchScripts(byIds ids: [UUID]) async throws -> [ScriptedIdea] {
        // Supabase .in() expects an array of strings
        let stringIds = ids.map { $0.uuidString }
        
        let result: [ScriptedIdea] = try await client.database
            .from("scripted_ideas")
            .select()
            .in("id", value: stringIds)
            .execute()
            .value
        
        return result
    }
    
    func fetchScriptById(id: UUID) async throws -> ScriptedIdea {
        
        let result: ScriptedIdea = try await client.database
            .from("scripted_ideas")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
        
        return result
    }
    
    func fetchScriptByIdeaId(ideaId: UUID) async throws -> ScriptedIdea? {
        let result: [ScriptedIdea] = try await client.database
            .from("scripted_ideas")
            .select("*, conversations!inner(idea_id)")
            .eq("conversations.idea_id", value: ideaId.uuidString)
            .limit(1)
            .execute()
            .value
        
        return result.first
    }
    
    func generateConversationTitleWithApple(
        messages: [ChatMessageDB]
    ) async throws -> String {
        
        guard !messages.isEmpty else {
            return "New Chat"
        }
        
        let context = messages
            .prefix(4)
            .map { "\($0.role.rawValue): \($0.content)" }
            .joined(separator: "\n")
        
        let prompt = """
        You are naming a chat conversation.
        
        Conversation:
        \(context)
        
        Rules:
        - Maximum 6 words
        - No quotes
        - No emojis
        - No punctuation at the end
        - Title case
        - Return ONLY the title text
        
        Output:
        """
        
        let rawTitle = try await AppleIntelligenceManager.shared.askSafely(prompt: prompt)
        
        return cleanTitle(rawTitle)
    }
    
    private func cleanTitle(_ text: String) -> String {
        
        var title = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "\n", with: "")
        
        // Limit to 6 words max
        let words = title.split(separator: " ")
        if words.count > 6 {
            title = words.prefix(6).joined(separator: " ")
        }
        
        if title.isEmpty {
            return "New Chat"
        }
        
        return title
    }
    
    func updateConversationTitle(
        conversationID: UUID,
        title: String
    ) async throws {
        
        try await client.database
            .from("conversations")
            .update(["title": title])
            .eq("id", value: conversationID.uuidString)
            .execute()
    }
    
    func generateAndStoreTitleIfNeeded(conversationID: UUID) async throws {
        
        // Fetch conversation
        let conversations: [Conversation] = try await client.database
            .from("conversations")
            .select("id, user_id, title, created_at")
            .eq("id", value: conversationID)
            .execute()
            .value
        
        guard let conversation = conversations.first else { return }
        
        // Prevent regenerating
        if let title = conversation.title,
           !title.isEmpty,
           title != "New Chat" {
            return
        }
        
        // Fetch messages
        let messages = try await fetchMessages(for: conversationID)
        
        // Wait until meaningful context exists
        guard messages.count >= 3 else { return }
        
        // Generate title
        let generatedTitle = try await generateConversationTitleWithApple(
            messages: messages
        )
        
        // Update DB
        try await updateConversationTitle(
            conversationID: conversationID,
            title: generatedTitle
        )
    }
    
    func deleteConversation(id: UUID) async throws {
        try await client.database
            .from("conversations")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    func upsertScriptField(
        chatID: UUID,
        field: String,
        value: String?
    ) async throws {
        
        let session = try await client.auth.session
        
        let payload = ScriptedIdeaInsertPayload(
            user_id: session.user.id,
            chat_id: chatID,
            title: field == "title" ? value : nil,
            description: field == "description" ? value : nil,
            script: field == "script" ? value : nil,
            thumbnail: field == "thumbnail" ? value : nil,
            hashtags: nil,
        )
        
        try await client.database
            .from("scripted_ideas")
            .upsert(payload, onConflict: "chat_id")
            .execute()
    }
    
    func updateExpandedDescription(
        ideaID: UUID,
        expandedDescription: String
    ) async throws {
        
        try await client.database
            .from("ideas")
            .update([
                "expanded_description": expandedDescription
            ])
            .eq("id", value: ideaID.uuidString)
            .execute()
        
        print("Expanded description saved")
    }
    
    func updatePlatform(id: UUID, platform: String) async throws {
        try await client.database
            .from("conversations")
            .update(["platform": platform])
            .eq("id", value: id.uuidString)
            .execute()
    }
    
}


