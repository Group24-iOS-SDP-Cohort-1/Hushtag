import Foundation
import Functions
import Supabase

nonisolated struct YouTubeDeletePayload: Encodable, Sendable {
    let upload_id: String
    let youtube_video_id: String?
}

nonisolated struct YouTubeUpdatePayload: Encodable, Sendable {
    let upload_id: String
    let youtube_video_id: String?
    let title: String
    let description: String?
    let tags: [String]?
    let categoryId: String?
    let privacyStatus: String?
    let publishAt: String?
}

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

    func deleteUpload(uploadId: UUID, youtubeVideoId: String?) async throws {
        let session = try await client.auth.session
        let payload = YouTubeDeletePayload(
            upload_id: uploadId.uuidString,
            youtube_video_id: youtubeVideoId
        )

        do {
            try await client.functions.invoke(
                "youtube-delete-video",
                options: .init(
                    headers: [
                        "Authorization": "Bearer \(session.accessToken)"
                    ],
                    body: payload
                )
            )
        } catch let FunctionsError.httpError(code, data) {
            var message = "Edge Function error \(code)"
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let err = json["error"] as? String {
                message = err
            } else if let str = String(data: data, encoding: .utf8) {
                message = str
            }
            print("❌ Delete Edge Function Error (\(code)): \(message)")
            throw NSError(domain: "YouTubeDelete", code: code, userInfo: [NSLocalizedDescriptionKey: message])
        } catch {
            print("❌ Delete error: \(error)")
            throw error
        }
    }

    func updateUpload(
        uploadId: UUID,
        youtubeVideoId: String?,
        title: String,
        description: String?,
        tags: [String]?,
        categoryId: String?,
        privacyStatus: String?,
        publishAt: Date?
    ) async throws {
        let session = try await client.auth.session
        let isoFormatter = ISO8601DateFormatter()
        let publishAtString = publishAt != nil ? isoFormatter.string(from: publishAt!) : nil

        let payload = YouTubeUpdatePayload(
            upload_id: uploadId.uuidString,
            youtube_video_id: youtubeVideoId,
            title: title,
            description: description,
            tags: tags,
            categoryId: categoryId,
            privacyStatus: privacyStatus,
            publishAt: publishAtString
        )

        do {
            try await client.functions.invoke(
                "youtube-update-video",
                options: .init(
                    headers: [
                        "Authorization": "Bearer \(session.accessToken)"
                    ],
                    body: payload
                )
            )
        } catch let FunctionsError.httpError(code, data) {
            var message = "Edge Function error \(code)"
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let err = json["error"] as? String {
                message = err
            } else if let str = String(data: data, encoding: .utf8) {
                message = str
            }
            print("❌ Update Edge Function Error (\(code)): \(message)")
            throw NSError(domain: "YouTubeUpdate", code: code, userInfo: [NSLocalizedDescriptionKey: message])
        } catch {
            print("❌ Update error: \(error)")
            throw error
        }
    }
}
