import Foundation

func generateTitleWithApple(
    script: String?,
    userPrompt: String
) async throws -> String {

    let contextBlock: String
    if let script = script {
        contextBlock = """
        Script context:
        \(script)
        """
    } else {
        contextBlock = """
        Context:
        Generate a title based on the user request.
        """
    }

    let prompt = """
    You are a social media copywriter.

    \(contextBlock)

    User request:
    "\(userPrompt)"

    Task:
    Generate 5 catchy, Gen-Z friendly titles with emojis.
    """

    return try await AppleIntelligenceManager.shared.askSafely(prompt: prompt)
}

func generateDescriptionWithApple(
    script: String?,
    userPrompt: String
) async throws -> String {

    let contextBlock: String
    if let script = script {
        contextBlock = """
        Script context:
        \(script)
        """
    } else {
        contextBlock = """
        Context:
        Generate a description based on the user request.
        """
    }

    let prompt = """
    You are writing an Instagram caption.

    \(contextBlock)

    User request:
    "\(userPrompt)"

    Task:
    Write a short, engaging description.
    Include emojis and 3–5 hashtags.
    """

    return try await AppleIntelligenceManager.shared.askSafely(prompt: prompt)
}
