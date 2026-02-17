import Foundation

final class SupabaseEdgeService {

    static let shared = SupabaseEdgeService()
    private init() {}

    private let url = URL(string:
        "https://juuuwuydlgjhgwwabswy.supabase.co/functions/v1/preference-search"
    )!

    private let anonKey =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp1dXV3dXlkbGdqaGd3d2Fic3d5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkwMTEwMzAsImV4cCI6MjA4NDU4NzAzMH0.qTJ2zoIj3uBR5tSOp8-J-dU0ZPJIE_XKkw23zP4-sRg"

    func fetchClusterIdeas(
        clusters: [String],
        completion: @escaping (Result<[ClusterIdea], Error>) -> Void
    ) {

        // ✅ No request struct needed
        let jsonObject: [String: Any] = [
            "clusters": clusters
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject) else {
            completion(.failure(NSError(domain: "Encoding Error", code: 0)))
            return
        }

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")

        // Call API
        URLSession.shared.dataTask(with: request) { data, _, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(
                    ClusterIdeaAPIResponse.self,
                    from: data
                )

                DispatchQueue.main.async {
                    completion(.success(decoded.results))
                }

            } catch {
                print("❌ Decode error:", error)
                completion(.failure(error))
            }

        }.resume()
    }

}
