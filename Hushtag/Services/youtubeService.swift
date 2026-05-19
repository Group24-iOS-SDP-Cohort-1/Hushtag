import Foundation

final class YouTubeService {

    func search(query: String) async throws -> SearchResponse {

        let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp1dXV3dXlkbGdqaGd3d2Fic3d5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkwMTEwMzAsImV4cCI6MjA4NDU4NzAzMH0.qTJ2zoIj3uBR5tSOp8-J-dU0ZPJIE_XKkw23zP4-sRg"

        let url = URL(string:
                        "https://juuuwuydlgjhgwwabswy.supabase.co/functions/v1/YouTube-search"
        )!

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
        let decoded = try decoder.decode(SearchResponse.self, from: data)
        return decoded
    }
}
