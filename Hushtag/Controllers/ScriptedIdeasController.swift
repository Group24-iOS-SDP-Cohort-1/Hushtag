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
    
    func addConversation(id: UUID) async throws -> Conversation {

        let session = try await client.auth.session

        let payload = ConversationInsertPayload(
            id: id,
            user_id: session.user.id
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
            .select()
            .eq("user_id", value: session.user.id.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value

        return result
    }

    
    func updateScript() {
        
    }
    
    func addScript(_ script: ScriptedIdea) async throws -> ScriptedIdeaDB{
        let session = try await client.auth.session
        
        let payload = ScriptedIdeaInsertPayload(
            user_id: session.user.id,
            chat_id: script.chat_id,
            title: script.title,
            description: script.description,
            script: script.script,
            thumbnail: script.thumbnailURL,
            hashtags: script.tags,
            mock_title: script.mockTitle,
            mock_description: script.mockDescription
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

}
