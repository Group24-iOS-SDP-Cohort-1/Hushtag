import Foundation

enum AppConfig {
    static func value(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: "keys", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let value = plist[key] as? String
        else {
            fatalError("Missing key: \(key)")
        }

        return value
    }
}

enum Keys {
    static let anonKey = AppConfig.value(for: "AnonKey")
    static let supabaseURL = AppConfig.value(for: "SupabaseURL")
    static let youtubeSearch = AppConfig.value(for: "SupabaseURL") + "/functions/v1/YouTube-search"
    static let preferenceSearch = AppConfig.value(for: "SupabaseURL") + "/functions/v1/preference-search"
    static let chatWithGemini = AppConfig.value(for: "SupabaseURL") + "/functions/v1/chat-with-gemini"
}

final class YouTubeService {
    func search(query: String) async throws -> SearchResponse {
        let anonKey = Keys.anonKey

        let url = URL(string: Keys.youtubeSearch)!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // REQUIRED HEADERS (BOTH)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.addValue(anonKey, forHTTPHeaderField: "apikey")

        let body = YouTubeSearchRequest(
            query: query
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: request)

        print("RAW RESPONSE:", String(data: data, encoding: .utf8) ?? "nil")

        // let decoded = try JSONDecoder().decode(SearchResponse.self, from: data)
        let decoder = JSONDecoder()
        return try decoder.decode(SearchResponse.self, from: data)
    }
}
