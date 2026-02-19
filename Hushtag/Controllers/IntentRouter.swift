import Foundation

enum Intent {
    case generateScript
    case generateTitle
    case generateDescription
    case chat
}

@available(iOS 18.0, *)
func classifyIntent(_ text: String) async throws -> Intent {

    let prompt = """
    Classify the user's intent into ONE category only:
    - generate_script
    - generate_title
    - generate_description
    - chat

    User message:
    "\(text)"

    Respond with ONLY the category name.
    """

    let response = try await AppleIntelligenceManager.shared.ask(prompt: prompt)
    let result = response.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

    switch result {
    case "generate_script":
        return .generateScript
    case "generate_title":
        return .generateTitle
    case "generate_description":
        return .generateDescription
    default:
        return .chat
    }
}
