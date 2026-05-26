import Foundation
import Supabase

extension ScriptedIdeasController {
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
        if field == "title" {
            title = value
        } else if field == "description" {
            description = value
        } else if field == "script" {
            script = value
        } else if field == "thumbnail" {
            thumbnail = value
        }

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
