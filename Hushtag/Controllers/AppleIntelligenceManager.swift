import Foundation
import FoundationModels

/// Low-level Apple Foundation Model access.
/// This file ONLY knows how to talk to Apple safely.
final class AppleIntelligenceManager {
    static let shared = AppleIntelligenceManager()
    private init() {}

    func askSafely(prompt: String) async throws -> String {
        // Platform availability check
        guard #available(iOS 18.0, *) else {
            throw AIError.unavailable
        }

        // Model availability check
        if #available(iOS 26.0, *) {
            guard SystemLanguageModel.default.availability == .available else {
                throw AIError.unavailable
            }
        } else {
            // Fallback on earlier versions
        }

        // Create session and ask
        guard #available(iOS 26.0, *) else {
            throw NSError(
                domain: "AppleIntelligence",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Apple Intelligence requires iOS 26+"]
            )
        }

        let session = LanguageModelSession()
        let response = try await session.respond(to: prompt)

        return response.content
    }

    enum AIError: Error, LocalizedError {
        case unavailable

        var errorDescription: String? {
            return "Apple Intelligence is not available on this device."
        }
    }
}
