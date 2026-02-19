import Foundation

@available(iOS 18.0, *)
func generateTitleWithApple(script: String) async throws -> String {

    let prompt = """
    You are a social media copywriter.

    Script for an Instagram Reel:
    \(script)

    Task:
    Generate 5 catchy, Gen-Z friendly titles.
    Use emojis where appropriate.
    """

    return try await AppleIntelligenceManager.shared.ask(prompt: prompt)
}

@available(iOS 18.0, *)
func generateDescriptionWithApple(script: String) async throws -> String {

    let prompt = """
    You are writing an Instagram caption.

    Script:
    \(script)

    Task:
    Write a short, engaging description.
    Include emojis and 3–5 relevant hashtags.
    """

    return try await AppleIntelligenceManager.shared.ask(prompt: prompt)
}



