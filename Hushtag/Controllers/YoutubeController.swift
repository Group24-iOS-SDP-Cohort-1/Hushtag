import Foundation
import Supabase

// MARK: - Edge Function Payloads

/// Payload sent to the 'youtube-auth' function to securely save tokens
struct YouTubeAuthPayload: Codable {
    let access_token: String
    let refresh_token: String
}

/// Payload sent to the 'fetch-youtube-analytics' proxy function
struct AnalyticsRequestPayload: Codable {
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
    func saveYouTubeTokens(accessToken: String, refreshToken: String) async throws {
            
            // 👉 DIAGNOSTIC CHECK: Are we actually logged in?
            do {
                let session = try await client.auth.session
                print("🟢 SUPABASE AUTH OK: Logged in as \(session.user.id)")
                
                let payload = YouTubeAuthPayload(access_token: accessToken, refresh_token: refreshToken)
                            try await client.functions.invoke("youtube-auth", options: .init(body: payload))
                            print("✅ Tokens successfully encrypted and saved via backend proxy.")
            } catch {
                print("🔴 SUPABASE AUTH FAILED: No active session found!")
                if let functionError = error as? FunctionsError,
                               case .httpError(let code, let data) = functionError,
                               let errorMessage = String(data: data, encoding: .utf8) {
                                print("🔴 EDGE FUNCTION FAILED (Code \(code)): \(errorMessage)")
                            } else {
                                print("🔴 SUPABASE ERROR: \(error)")
                            }
                            throw error
                //throw error // This will stop the function before it hits the 401
            }
            
            let payload = YouTubeAuthPayload(
                access_token: accessToken,
                refresh_token: refreshToken
            )

            print("🚀 Sending tokens to Edge Function for secure storage...")
            
            try await client.functions
                .invoke(
                    "youtube-auth",
                    options: .init(body: payload)
                )
            
            print("✅ Tokens successfully encrypted and saved via backend proxy.")
        }
    
    // MARK: - 2. Fetch Analytics Data
        
        /// Calls the proxy Edge Function to get the user's YouTube views
        func fetchAnalytics(startDate: String, endDate: String) async throws -> Data {
            
            let payload = AnalyticsRequestPayload(
                startDate: startDate,
                endDate: endDate
            )
            
            print("📊 Requesting analytics from Edge Function...")
            
            // Invoke the fetch-youtube-analytics Edge Function and capture raw Data
            let responseData: Data = try await client.functions
                .invoke(
                    "fetch-youtube-analytics",
                    options: .init(body: payload),
                    decode: { data, response in
                        return data // 👉 THE FIX: Explicitly return the raw Data
                    }
                )
            
            return responseData
        }
}
