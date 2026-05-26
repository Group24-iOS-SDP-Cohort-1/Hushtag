import Foundation
import Supabase

final class ScriptedIdeasController {
    let client = SupabaseConfig.client

    func addChatMessage(id: UUID, sender: Role, content: String) async throws -> ChatMessageDB {
        let payload = ChatMessageInsertPayload(
            conversationId: id,
            role: sender,
            content: content
        )

        return try await client.database
            .from("chat_history")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
    }

    func addConversation(id: UUID, ideaId: UUID? = nil) async throws -> Conversation {
        let session = try await client.auth.session

        let payload = ConversationInsertPayload(
            id: id,
            userId: session.user.id,
            ideaId: ideaId
        )

        return try await client.database
            .from("conversations")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
    }

    func getBotMessage() async throws -> ChatMessageDB {
        return try await client.database.from("chat_history").select().eq("role", value: "bot").execute().value
    }

    func fetchConversations() async throws -> [Conversation] {
        let session = try await client.auth.session

        return try await client.database
            .from("conversations")
            .select("""
                id,
                userId,
                title,
                createdAt,
            ideaId,
                chat_history!inner(conversationId),
                scripted_ideas (
                    id,
                    chatId,
                    title,
                    description,
                    script,
                    thumbnail
                )
            """)
            .eq("userId", value: session.user.id.uuidString)
            .order("createdAt", ascending: false)
            .execute()
            .value
    }

    func fetchConversation(for ideaId: UUID) async throws -> Conversation? {
        let result: [Conversation] = try await client.database
            .from("conversations")
            .select("""
                id,
                userId,
                title,
                createdAt,
                scripted_ideas (
                    id,
                    chatId,
                    title,
                    description,
                    script,
                    thumbnail
                )
            """)
            .eq("ideaId", value: ideaId.uuidString)
            .limit(1)
            .execute()
            .value

        return result.first
    }

    func updateScript(id: UUID, title: String?, description: String?, script: String?) async throws {
        var payload: [String: String] = [:]
        if let title = title { payload["title"] = title }
        if let description = description { payload["description"] = description }
        if let script = script { payload["script"] = script }

        guard !payload.isEmpty else { return }

        try await client.database
            .from("scripted_ideas")
            .update(payload)
            .eq("id", value: id.uuidString)
            .execute()
    }

    func deleteScript(id: UUID) async throws {
        try await client.database
            .from("scripted_ideas")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }

    func addScript(_ script: ScriptedIdea) async throws -> ScriptedIdeaDB {
        let session = try await client.auth.session

        let payload = ScriptedIdeaInsertPayload(
            userId: session.user.id,
            chatId: script.chatId,
            title: script.title,
            description: script.description,
            script: script.script,
            thumbnail: script.thumbnail,
            hashtags: script.tags
        )

        return try await client.database
            .from("scripted_ideas")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
    }

    func fetchScript() async throws -> [ScriptedIdea] {
        return try await client.database.from("scripted_ideas").select().execute().value
    }

    func fetchMessages(for conversationID: UUID) async throws -> [ChatMessageDB] {
        return try await client.database
            .from("chat_history")
            .select()
            .eq("conversationId", value: conversationID.uuidString)
            .order("createdAt", ascending: true)
            .execute()
            .value
    }

    /// Fetches specific scripted ideas by their IDs.
    func fetchScripts(byIds ids: [UUID]) async throws -> [ScriptedIdea] {
        // Supabase .in() expects an array of strings
        let stringIds = ids.map { $0.uuidString }

        return try await client.database
            .from("scripted_ideas")
            .select()
            .in("id", value: stringIds)
            .execute()
            .value
    }

    func fetchScriptById(id: UUID) async throws -> ScriptedIdea {
        return try await client.database
            .from("scripted_ideas")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
    }

    func fetchScriptByIdeaId(ideaId: UUID) async throws -> ScriptedIdea? {
        let result: [ScriptedIdea] = try await client.database
            .from("scripted_ideas")
            .select("*, conversations!inner(ideaId)")
            .eq("conversations.ideaId", value: ideaId.uuidString)
            .limit(1)
            .execute()
            .value

        return result.first
    }

    func deleteConversation(id: UUID) async throws {
        try await client.database
            .from("conversations")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
}
