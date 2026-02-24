//
//  AIResponseRouter.swift
//  Hushtag
//
//  Created by SDC-USER on 24/02/26.
//
import Foundation
final class AIResponseRouter {

    static let shared = AIResponseRouter()
    private init() {}

    enum Intent {
        case script
        case title
        case description
        case chat
    }

    func respond(
        intent: Intent,
        prompt: String,
        conversationID: UUID?
    ) async -> String {

        switch intent {

        // 🌐 Heavy creative work → Gemini ONLY
        case .script:
            return await callGemini(
                prompt: prompt,
                conversationID: conversationID
            )

        // 🍎 Refinement / chat → Apple → Gemini fallback
        case .title, .description, .chat:
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
