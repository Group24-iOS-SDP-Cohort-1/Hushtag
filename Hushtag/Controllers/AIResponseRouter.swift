import Foundation

final class AIResponseRouter {
    
    static let shared = AIResponseRouter()
    private init() {}
    
    enum Intent {
        case generateScript
        case generateTitle
        case generateDescription
        case chat
    }
    
    func respond(
        intent: Intent,
        prompt: String,
        conversationID: UUID?
    ) async -> String {
        
        switch intent {
            
            // 🌐 Heavy creative work → Gemini ONLY
        case .generateScript:
            return await callGemini(
                prompt: prompt,
                conversationID: conversationID
            )
            
            // 🍎 Refinement / chat → Apple → Gemini fallback
        case . generateTitle, .generateDescription, .chat:
            do {
                let reply = try await AppleIntelligenceManager.shared.askSafely(
                    prompt: prompt
                )
                print("🍎 Apple Intelligence used (\(intent))")
                return reply
            } catch {
                print("⚠️ Apple unavailable → Gemini fallback (\(intent))")
                return await callGemini(
                    prompt: prompt,
                    conversationID: conversationID
                )
            }
        }
    }
    
    private func callGemini(
        prompt: String,
        conversationID: UUID?
    ) async -> String {
        
        await withCheckedContinuation { continuation in
            GeminiManager.shared.generateContent(
                prompt: prompt,
                conversationID: conversationID ?? UUID()
            ) { reply in
                continuation.resume(
                    returning: reply ?? "Something went wrong."
                )
            }
        }
    }
}

extension AIResponseRouter {
    
    func classifyIntent(
        message: String,
        conversationID: UUID?,
        platform: String? = nil
    ) async -> Intent {

        let _ = platform.map { "Platform: \($0)" } ?? ""

        let prompt = """
        You are an intent classifier for a content creation app.
        
        Classify the user's message into ONE of the following categories:
        - script
        - title
        - description
        - chat
        
        Rules:
        - Respond with ONLY the category name.
        - No explanations.
        - Lowercase only.
        
        User message:
        "\(message)"
        """
        
        let reply = await respond(
            intent: .chat, // Apple first, Gemini fallback
            prompt: prompt,
            conversationID: conversationID
        )
        
        switch reply.trimmingCharacters(in: .whitespacesAndNewlines) {
        case "script":
            return .generateScript
        case "title":
            return .generateTitle
        case "description":
            return .generateDescription
        default:
            return .chat
        }
    }
}
