import Foundation
import Supabase

// MARK: - Edge Function Payloads

/// Payload sent to the 'youtube-auth' function to securely save tokens
struct YouTubeAuthPayload: Codable {
    let action: String
    let access_token: String
    let refresh_token: String
}

struct AnalyticsRequestPayload: Codable {
    let action: String
    let startDate: String
    let endDate: String
}



// MARK: - YouTube Controller

final class YouTubeController {
    
    static let shared = YouTubeController()
    private init() {}
    
    // Assuming you have a SupabaseConfig setup in your project
    private let client = SupabaseConfig.client
    
    // MARK: - 1. Secure Token Storage
    
    /// Sends the raw tokens to the backend to be securely encrypted and saved.
    func saveYouTubeTokens(
        accessToken: String,
        refreshToken: String
    ) async throws {
        
        let session = try await client.auth.session
        print("🟢 SUPABASE AUTH OK: \(session.user.id)")
        
        let payload = YouTubeAuthPayload(
            action: "save_tokens",
            access_token: accessToken,
            refresh_token: refreshToken
        )
        
        print("🚀 Sending tokens to unified YouTube function...")
        
        try await client.functions.invoke(
            "youtube-auth",
            options: .init(
                headers: [
                    "Authorization": "Bearer \(session.accessToken)"
                ],
                body: payload
            )
        )
        
        print("✅ Tokens encrypted & saved")
    }
    
    // MARK: - 2. Fetch Analytics Data
    
    /// Calls the proxy Edge Function to get the user's YouTube views
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
    
    // MARK: - 3. Check Connection State
    
    /// Checks if the current user has connected their YouTube account by verifying if a token row exists
    func checkYouTubeConnection() async -> Bool {
        do {
            let session = try await client.auth.session
            
            // Bypass Strict Concurrency Codable struct mismatches with a plain Sendable Dictionary
            let _: [String: String] = try await client.database
                .from("youtube_tokens")
                .select("user_id")
                .eq("user_id", value: session.user.id)
                .single()
                .execute()
                .value
            
            return true
        } catch {
            print("YouTube connection check Failed or Not Found: \(error)")
            return false
        }
    }
    
    func restoreYouTubeConnectionIfNeeded() async {
        do {
            let isConnected = await checkYouTubeConnection()
            
            guard isConnected else {
                print("⚠️ No YouTube connection found")
                return
            }
            
            print("✅ YouTube already connected")
            
            // CALL ANALYTICS HERE
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            let endDate = formatter.string(from: Date())
            let startDate = formatter.string(
                from: Calendar.current.date(byAdding: .day, value: -28, to: Date())!
            )
            
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
}

extension Notification.Name {
    static let analyticsUpdated = Notification.Name("analyticsUpdated")
}
