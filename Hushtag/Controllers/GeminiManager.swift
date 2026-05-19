import Foundation

final class GeminiManager {
    static let shared = GeminiManager()

    private let functionURL = Keys.chatWithGemini

    private let anonKey = SupabaseConfig.anonKey

    private init() {}

    func generateContent(
        prompt: String,
        conversationID: UUID,
        completion: @escaping (String?) -> Void
    ) {
        guard let url = URL(string: functionURL) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Supabase headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")

        // Request body
        let body: [String: String] = [
            "prompt": prompt,
            "conversationId": conversationID.uuidString
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error:", error)
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            // ✅ READ PLAIN TEXT RESPONSE
            let textResponse = String(data: data, encoding: .utf8)

            // Optional: read conversation id from headers
            if let httpResponse = response as? HTTPURLResponse {
                let returnedConversationId =
                    httpResponse.value(forHTTPHeaderField: "X-Conversation-Id")

                print("🧠 Conversation ID:", returnedConversationId ?? "nil")
            }

            print("✅ Gemini response:", textResponse ?? "nil")

            completion(textResponse)

        }.resume()
    }
}
