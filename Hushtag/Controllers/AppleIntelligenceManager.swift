//
//  AppleIntelligenceManager.swift
//  Hushtag
//
//  Created by SDC-USER on 09/02/26.
//

import Foundation
import FoundationModels

// This class is generic. You can use it to ask ANYTHING from anywhere.
final class AppleIntelligenceManager {
    
    static let shared = AppleIntelligenceManager()
    
    private init() {}
    
    // Checks if Apple Intelligence is supported and ready on this device
    var isAvailable: Bool {
        if #available(iOS 18.0, *) {
            return SystemLanguageModel.default.availability == .available
        }
        return false
    }
    
    // Sends a prompt to the on-device model and returns the text response
    @available(iOS 18.0, *)
    func ask(prompt: String) async throws -> String {
        guard isAvailable else {
            throw AIError.unavailable
        }
        
        let session = LanguageModelSession()
        let response = try await session.respond(to: prompt)
        return response.content
    }
    
    enum AIError: Error, LocalizedError {
        case unavailable
        var errorDescription: String? {
            return "Apple Intelligence is not available or models are not downloaded."
        }
    }
}
