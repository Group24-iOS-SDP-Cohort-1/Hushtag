import Foundation
import Supabase

struct YouTubeAuthPayload: Codable {
    let action: String
    let server_auth_code: String
}

struct AnalyticsRequestPayload: Codable {
    let action: String
    let startDate: String
    let endDate: String
}

struct ChannelMetricsPayload: Codable {
    let id: String
    let title: String
    let niche: String?
    let subscribers: Int
    let postingFrequencyPerWeek: Int?
    let audienceGeo: [String]?
}

struct GroqVideoPayload: Codable {
    let title: String
    let views: Int
    let likes: Int
    let comments: Int
    let duration: Int
    let publishedAt: String
}

struct YoutubeIdeaGeneratorPayload: Codable {
    let analytics: AudienceMetrics?
    let videos: [GroqVideoPayload]
    let channel: ChannelMetricsPayload
}

struct AnalyticsIdea: Codable, Identifiable {
    var id: UUID = UUID()
    let title: String
    let hook: String
    let why_it_will_work: [String]
    let target_emotion: String
    let format: String
    let estimated_virality_score: Double
    struct ThumbnailConcept: Codable {
        let text: String
        let visual: String
    }
    let thumbnail_concept: ThumbnailConcept?
    let opening_30_seconds: [String]
    let content_pillars: [String]
    let risks: [String]
    let difficulty: String
    let estimated_ctr: Double
    let estimated_retention: Double

    enum CodingKeys: String, CodingKey {
        case title, hook, why_it_will_work, target_emotion, format, estimated_virality_score, thumbnail_concept, opening_30_seconds, content_pillars, risks, difficulty, estimated_ctr, estimated_retention
    }
}

struct YoutubeIdeaGeneratorResponse: Codable {
    let generatedAt: String
    let ideas: [AnalyticsIdea]
}

final class YouTubeController {

    static let shared = YouTubeController()
    private init() {}

    private let client = SupabaseConfig.client

    func saveYouTubeTokens(
        serverAuthCode: String
    ) async throws {

        let session = try await client.auth.session
        // print("🟢 SUPABASE AUTH OK: \(session.user.id)")

        let payload = YouTubeAuthPayload(
            action: "exchange_and_save_tokens",
            server_auth_code: serverAuthCode
        )

        // print("🚀 Sending tokens to unified YouTube function...")
        try await client.functions.invoke(
            "youtube-auth",
            options: .init(
                headers: [
                    "Authorization": "Bearer \(session.accessToken)"
                ],
                body: payload
            )
        )

        // print("✅ Tokens encrypted & saved")
    }

    func fetchAnalytics(
        startDate: String,
        endDate: String
    ) async throws -> Data {

        let session = try await client.auth.session

        let payload = AnalyticsRequestPayload(
            action: "fetch_analytics",
            startDate: startDate,
            endDate: endDate
        )

        let responseData: Data =
        try await client.functions.invoke(
            "youtube-auth",
            options: .init(
                headers: [
                    "Authorization": "Bearer \(session.accessToken)"
                ],
                body: payload
            ),
            decode: { data, _ in data }
        )

        return responseData
    }

    nonisolated struct ConnectionStatus: Decodable {
        let is_youtube_connected: Bool?
    }

    func checkYouTubeConnection() async -> Bool {

        do {
            let session = try await client.auth.session

            let status: ConnectionStatus = try await client.database
                .from("profiles")
                .select("is_youtube_connected")
                .eq("user_id", value: session.user.id)
                .single()
                .execute()
                .value

            return status.is_youtube_connected ?? false

        } catch {
            // print("YouTube connection check Failed or Not Found: \(error)")
            return false
        }
    }

    func restoreYouTubeConnectionIfNeeded(
        startDate: String,
        endDate: String
    ) async {

        print("📅 Start date being sent:", startDate)
        print("📅 End date being sent:", endDate)

        do {
            let isConnected = await checkYouTubeConnection()

            guard isConnected else {
                print("⚠️ No YouTube connection found")
                return
            }

            // print("✅ YouTube already connected")

            let data = try await fetchAnalytics(
                startDate: startDate,
                endDate: endDate
            )

            print("📊 ANALYTICS RESPONSE:")
            print(String(data: data, encoding: .utf8) ?? "No data")

            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .analyticsUpdated,
                    object: data
                )
            }

        } catch {
            print("❌ Analytics auto-fetch failed:", error)
        }
    }

    func disconnectYouTubeBackend() async throws {
            let session = try await client.auth.session

            let payload = YouTubeAuthPayload(
                action: "disconnect",
                server_auth_code: ""
            )

            try await client.functions.invoke(
                "youtube-auth",
                options: .init(
                    headers: ["Authorization": "Bearer \(session.accessToken)"],
                    body: payload
                )
            )
        }

    func generateIdeas(payload: YoutubeIdeaGeneratorPayload) async throws -> [AnalyticsIdea] {
        let session = try await client.auth.session

        let responseData: Data = try await client.functions.invoke(
            "rapid-worker",
            options: .init(
                headers: [
                    "Authorization": "Bearer \(session.accessToken)"
                ],
                body: payload
            ),
            decode: { data, _ in data }
        )

        let decoder = JSONDecoder()
        let response = try decoder.decode(YoutubeIdeaGeneratorResponse.self, from: responseData)

        return response.ideas
    }
}

extension Notification.Name {
    static let analyticsUpdated = Notification.Name("analyticsUpdated")
}
