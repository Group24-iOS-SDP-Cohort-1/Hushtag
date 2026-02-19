import Foundation
import FoundationModels

// Low-level Apple Foundation Model access.
// This file ONLY knows how to talk to Apple safely.
final class AppleIntelligenceManager {

    static let shared = AppleIntelligenceManager()
    private init() {}

    /// Safe entry point for asking Apple Intelligence.
    /// Callers never check availability or iOS version.
    func askSafely(prompt: String) async throws -> String {

        // 1️⃣ Platform availability check
        guard #available(iOS 18.0, *) else {
            throw AIError.unavailable
        }

        // 2️⃣ Model availability check
        guard SystemLanguageModel.default.availability == .available else {
            throw AIError.unavailable
        }

        // 3️⃣ Create session and ask
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
