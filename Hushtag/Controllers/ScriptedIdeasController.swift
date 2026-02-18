import Foundation
import Supabase

final class ScriptedIdeasController {
    
    private let client = SupabaseConfig.client
    
    func addChatMessage(sender: Role, content: String) async throws -> ChatMessageDB {

            let payload = ChatMessageInsertPayload(
                role: sender,
                message: content
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

    
    func getBotMessage() async throws -> ChatMessageDB {
        let chats: ChatMessageDB = try await client.database.from("chat_history").select().eq("role", value: "bot").execute().value
        
        return chats
    }
    
    func fetchChatHistory() async throws -> [ChatMessageDB] {
        let chats: [ChatMessageDB] = try await client.database.from("chat_history").select().execute().value
        
        return chats
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
            tags: script.tags,
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
}
