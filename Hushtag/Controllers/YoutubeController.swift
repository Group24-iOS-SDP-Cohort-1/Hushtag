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

final class YouTubeController {
    
    static let shared = YouTubeController()
    private init() {}
    
    private let client = SupabaseConfig.client
    
    
    func saveYouTubeTokens(
        serverAuthCode: String
    ) async throws {
        
        let session = try await client.auth.session
        //print("🟢 SUPABASE AUTH OK: \(session.user.id)")
        
        let payload = YouTubeAuthPayload(
            action: "exchange_and_save_tokens",
            server_auth_code: serverAuthCode
        )
        
        //print("🚀 Sending tokens to unified YouTube function...")
        try await client.functions.invoke(
            "youtube-auth",
            options: .init(
                headers: [
                    "Authorization": "Bearer \(session.accessToken)"
                ],
                body: payload
            )
        )
        
        //print("✅ Tokens encrypted & saved")
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
            //print("YouTube connection check Failed or Not Found: \(error)")
            return false
        }
    }
    
    func restoreYouTubeConnectionIfNeeded(
        startDate: String,
        endDate: String
    ) async {
        
        do {
            let isConnected = await checkYouTubeConnection()
            
            guard isConnected else {
                print("⚠️ No YouTube connection found")
                return
            }
            
            //print("✅ YouTube already connected")
            
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
}

extension Notification.Name {
    static let analyticsUpdated = Notification.Name("analyticsUpdated")
}
