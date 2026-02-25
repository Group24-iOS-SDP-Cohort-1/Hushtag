
import Foundation
import Supabase
import CryptoKit

// MARK: - Token Data Structure

nonisolated struct YouTubeTokens: Codable, Sendable {
    let user_id: UUID
    let access_token: String
    let refresh_token: String
}

// MARK: - Encryption Utility

struct TokenCrypto {
    static let symmetricKey = SymmetricKey(size: .bits256)
    
    static func encrypt(_ string: String) throws -> String {
        guard let data = string.data(using: .utf8) else {
            throw NSError(domain: "CryptoError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert string to data"])
        }
        let sealedBox = try ChaChaPoly.seal(data, using: symmetricKey)
        return sealedBox.combined.base64EncodedString()
    }
    
    static func decrypt(_ base64String: String) throws -> String {
        guard let data = Data(base64Encoded: base64String) else {
            throw NSError(domain: "CryptoError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to decode base64 string"])
        }
        let sealedBox = try ChaChaPoly.SealedBox(combined: data)
        let decryptedData = try ChaChaPoly.open(sealedBox, using: symmetricKey)
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw NSError(domain: "CryptoError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to decode decrypted data to string"])
        }
        return decryptedString
    }
}


final class YouTubeController {

    static let shared = YouTubeController()
    private init() {}

    private let client = SupabaseConfig.client

    /// Exchange Google OAuth auth code for YouTube access
    func exchangeAuthCode(_ code: String) async throws {

        let session = try await client.auth.session
        let userId = session.user.id.uuidString

        let payload = YouTubeAuthPayload(
            user_id: userId,
            auth_code: code
        )


        // 🔥 Call Supabase Edge Function
        try await client.functions
            .invoke(
                "youtube-auth",
                options: .init(body: payload)
            )
    }
    
    /// Save YouTube analytics access and refresh tokens to Supabase
    func saveYouTubeTokens(accessToken: String, refreshToken: String) async throws {
        let session = try await client.auth.session
        let userId = session.user.id
        
        print("🔑 DEBUG - Raw Access Token: \(accessToken)")
        print("🔄 DEBUG - Raw Refresh Token: \(refreshToken)")
        
        let encryptedAccess = try TokenCrypto.encrypt(accessToken)
        let encryptedRefresh = try TokenCrypto.encrypt(refreshToken)
        
        let tokenData = YouTubeTokens(
            user_id: userId,
            access_token: encryptedAccess,
            refresh_token: encryptedRefresh
        )
        
        try await client.database
            .from("youtube_tokens")
            .upsert(tokenData)
            .execute()
    }
}
