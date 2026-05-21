import Foundation
import Supabase

final class ScriptedIdeasController {
    private let client = SupabaseConfig.client

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

        do {
            let rawTitle = try await AppleIntelligenceManager.shared.askSafely(prompt: prompt)
            return cleanTitle(rawTitle)
        } catch {
            print("⚠️ Apple Intelligence Title generation failed, routing through AI router fallback")
            let rawTitle = await AIResponseRouter.shared.respond(
                intent: .chat,
                prompt: prompt,
                conversationID: nil
            )
            return cleanTitle(rawTitle)
        }
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
            .select("id, userId, title, createdAt")
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
        guard messages.count >= 2 else { return }

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

        // Fetch existing scripted idea first if any to avoid overwriting other fields with NULL
        let existingResult: [ScriptedIdeaDB] = try await client.database
            .from("scripted_ideas")
            .select()
            .eq("chatId", value: chatID.uuidString)
            .limit(1)
            .execute()
            .value

        let existing = existingResult.first

        // Prepare updated values by merging existing with target field update
        var title = existing?.title
        var description = existing?.description
        var script = existing?.script
        var thumbnail = existing?.thumbnail

        if field == "title" { title = value }
        else if field == "description" { description = value }
        else if field == "script" { script = value }
        else if field == "thumbnail" { thumbnail = value }

        let payload = ScriptedIdeaInsertPayload(
            userId: session.user.id,
            chatId: chatID,
            title: title,
            description: description,
            script: script,
            thumbnail: thumbnail,
            hashtags: existing?.tags
        )

        try await client.database
            .from("scripted_ideas")
            .upsert(payload, onConflict: "chatId")
            .execute()
    }

    func updateExpandedDescription(
        ideaID: UUID,
        expandedDescription: String
    ) async throws {
        try await client.database
            .from("ideas")
            .update([
                "expandedDescription": expandedDescription
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

    func insertIdeaIfNeeded(idea: Idea) async throws {
        let payload = IdeaInsertPayload(
            id: idea.id,
            title: idea.title,
            description: idea.description,
            format: idea.format,
            hashtags: idea.hashtags,
            noveltyScore: idea.noveltyScore
        )

        try await client.database
            .from("ideas")
            .upsert(payload)
            .execute()
    }
}
