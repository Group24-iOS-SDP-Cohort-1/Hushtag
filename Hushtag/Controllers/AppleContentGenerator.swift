import Foundation

func generateTitleWithApple(
    script: String?,
    userPrompt: String,
    conversationID: UUID?
) async -> String {
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
    Generate a youtube catchy, Gen-Z friendly title with no emojis and no quotes.
    """

    return await AIResponseRouter.shared.respond(
        intent: .generateTitle,
        prompt: prompt,
        conversationID: conversationID
    )
}

func generateDescriptionWithApple(
    script: String?,
    userPrompt: String,
    conversationID: UUID?
) async -> String {
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
    You are writing a Youtube caption.

    \(contextBlock)

    User request:
    "\(userPrompt)"

    Task:
    Write a short, engaging description.
    Include emojis and 3–5 hashtags.
    """

    return await AIResponseRouter.shared.respond(
        intent: .generateDescription,
        prompt: prompt,
        conversationID: conversationID
    )
}
