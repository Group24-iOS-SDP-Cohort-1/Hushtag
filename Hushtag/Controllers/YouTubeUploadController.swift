import Foundation
import Supabase

final class YouTubeUploadController: @unchecked Sendable {
    private let client = SupabaseConfig.client

    func fetchUploads() async throws -> [YouTubeUpload] {
        let session = try await client.auth.session
        let uploads: [YouTubeUpload] = try await client.database
            .from("creator_video_uploads")
            .select()
            .eq("userId", value: session.user.id)
            .order("createdAt", ascending: false)
            .execute()
            .value
        return uploads
    }
}
