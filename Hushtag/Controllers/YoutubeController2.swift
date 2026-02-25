
import Foundation
import Supabase


//final class YouTubeController {
//
//    static let shared = YouTubeController()
//    private init() {}
//
//    private let client = SupabaseConfig.client
//
//    /// Exchange Google OAuth auth code for YouTube access
//    func exchangeAuthCode(_ code: String) async throws {
//
//        let session = try await client.auth.session
//        let userId = session.user.id.uuidString
//
//        let payload = YouTubeAuthPayload(
//            user_id: userId,
//            auth_code: code
//        )
//
//
//        // 🔥 Call Supabase Edge Function
//        try await client.functions
//            .invoke(
//                "youtube-auth",
//                options: .init(body: payload)
//            )
//    }
//}
