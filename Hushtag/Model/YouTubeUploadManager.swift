import Foundation
import Supabase
import UIKit

struct GetResumableUrlResponse: Codable {
    let resumableUploadUrl: String
    let uploadId: String
}

struct AttachThumbnailRequest: Codable {
    let uploadId: String
    let youtubeVideoId: String

    enum CodingKeys: String, CodingKey {
        case uploadId = "upload_id"
        case youtubeVideoId = "youtube_video_id"
    }
}

struct VideoUploadRequest {
    let videoURL: URL
    let thumbnailURL: URL?
    let title: String
    let description: String?
    let tags: [String]?
    let categoryId: String
    let privacyStatus: String
    let publishAt: Date?
}

class YouTubeUploadManager: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    static let shared = YouTubeUploadManager()

    private let backgroundSessionID = "com.learningxcode.Hushtag.youtube.background.upload"

    lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: backgroundSessionID)
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        config.allowsCellularAccess = true

        if #available(iOS 13.0, *) {
            // 4. Allow upload even if the user is on a Personal Hotspot (Expensive Network)
            config.allowsExpensiveNetworkAccess = true

            // 5. Respect the user! If they turned on "Low Data Mode", pause the giant upload.
            // If you set this to true, you are forcing it through anyway (not recommended for gigabyte files).
            config.allowsConstrainedNetworkAccess = false
        }

        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    private var responseData = [Int: Data]()

    // Optional: completion handler to call when background session finishes
    var backgroundCompletionHandler: (() -> Void)?

    override private init() {
        super.init()
        // Initialize the session so delegates are attached immediately
        _ = urlSession
    }

    /// Main entry point to upload a video
    func uploadVideo(request: VideoUploadRequest) {
        Task {
            do {
                let persistentVideoURL = try copyVideoToPersistentStorage(from: request.videoURL)
                let session = try await SupabaseConfig.client.auth.session
                let jwtToken = session.accessToken
                print("🔑 RAW JWT: \(jwtToken)")
                let boundary = "Boundary-\(UUID().uuidString)"
                let parameters = buildUploadParameters(
                    request: request,
                    persistentVideoURL: persistentVideoURL
                )
                guard let resumableData = try await performHandshake(
                    jwtToken: jwtToken,
                    boundary: boundary,
                    parameters: parameters,
                    thumbnailURL: request.thumbnailURL
                ) else { return }
                guard let uploadUrl = URL(string: resumableData.resumableUploadUrl) else {
                    print("Invalid Resumable URL returned from backend")
                    return
                }
                var uploadRequest = URLRequest(url: uploadUrl)
                uploadRequest.httpMethod = "PUT"
                let uploadTask = urlSession.uploadTask(with: uploadRequest, fromFile: persistentVideoURL)
                uploadTask.taskDescription = resumableData.uploadId
                uploadTask.resume()
                print("🚀 Native Video Upload Task started with ID: \(resumableData.uploadId)")
            } catch {
                print("❌ Failed to orchestrate upload process: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Private Helpers

    private func copyVideoToPersistentStorage(from videoURL: URL) throws -> URL {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let persistentVideoURL = documentsDir.appendingPathComponent(videoURL.lastPathComponent)
        if FileManager.default.fileExists(atPath: persistentVideoURL.path) {
            try? FileManager.default.removeItem(at: persistentVideoURL)
        }
        try FileManager.default.copyItem(at: videoURL, to: persistentVideoURL)
        return persistentVideoURL
    }

    private func buildUploadParameters(
        request: VideoUploadRequest,
        persistentVideoURL: URL
    ) -> [String: String] {
        let isoFormatter = ISO8601DateFormatter()
        let finalPrivacy = request.publishAt != nil ? "private" : request.privacyStatus.lowercased()
        return [
            "title": request.title,
            "description": request.description ?? "",
            "tags": request.tags != nil ? "[\(request.tags!.map { "\"\($0)\"" }.joined(separator: ","))]" : "[]",
            "categoryId": request.categoryId,
            "privacyStatus": finalPrivacy,
            "publishAt": request.publishAt != nil ? isoFormatter.string(from: request.publishAt!) : "",
            "localVideoFilename": persistentVideoURL.lastPathComponent
        ]
    }

    private func performHandshake(
        jwtToken: String,
        boundary: String,
        parameters: [String: String],
        thumbnailURL: URL?
    ) async throws -> GetResumableUrlResponse? {
        let urlString = "https://juuuwuydlgjhgwwabswy.supabase.co/functions/v1/youtube-upload"
        var handshakeRequest = URLRequest(url: URL(string: urlString)!)
        handshakeRequest.httpMethod = "POST"
        handshakeRequest.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        await handshakeRequest.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        handshakeRequest.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )
        handshakeRequest.httpBody = buildMultipartBody(
            parameters: parameters,
            thumbnailURL: thumbnailURL,
            boundary: boundary
        )
        let (responseData, responseURL) = try await URLSession.shared.data(for: handshakeRequest)
        guard let httpResponse = responseURL as? HTTPURLResponse else {
            print("Invalid response from handshake")
            return nil
        }
        if !(200 ... 299).contains(httpResponse.statusCode) {
            if let errString = String(data: responseData, encoding: .utf8) {
                print("❌ Handshake failed (\(httpResponse.statusCode)): \(errString)")
            } else {
                print("❌ Handshake failed with status code: \(httpResponse.statusCode)")
            }
            return nil
        }
        return try JSONDecoder().decode(GetResumableUrlResponse.self, from: responseData)
    }

    private func attachThumbnailToVideo(uploadId: String, videoId: String) async throws {
        let session = try await SupabaseConfig.client.auth.session
        let jwtToken = session.accessToken
        let urlString = "https://juuuwuydlgjhgwwabswy.supabase.co/functions/v1/set-youtube-thumbnail"
        var thumbnailRequest = URLRequest(url: URL(string: urlString)!)
        thumbnailRequest.httpMethod = "POST"
        thumbnailRequest.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        await thumbnailRequest.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        thumbnailRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let reqBody = AttachThumbnailRequest(uploadId: uploadId, youtubeVideoId: videoId)
        thumbnailRequest.httpBody = try JSONEncoder().encode(reqBody)
        let (data, response) = try await URLSession.shared.data(for: thumbnailRequest)
        if let httpResponse = response as? HTTPURLResponse {
            if (200 ... 299).contains(httpResponse.statusCode) {
                print("✅ Thumbnail attachment and DB update triggered successfully!")
            } else {
                let errStr = String(data: data, encoding: .utf8) ?? "Unknown"
                print("❌ Thumbnail Edge Function failed (\(httpResponse.statusCode)): \(errStr)")
            }
        }
    }

    // MARK: - Multipart helpers

    private func buildMultipartBody(
        parameters: [String: String],
        thumbnailURL: URL?,
        boundary: String
    ) -> Data {
        var body = Data()
        for (key, value) in parameters {
            if key == "publishAt" && value.isEmpty { continue }
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
            body.append(Data("\(value)\r\n".utf8))
        }
        if let thumb = thumbnailURL, let thumbData = compressedThumbnailData(from: thumb) {
            let ext = "jpeg"
            let thumbName = "thumb.\(ext)"
            body.append(Data("--\(boundary)\r\n".utf8))
            body.append(
                Data("Content-Disposition: form-data; name=\"thumbnail\"; filename=\"\(thumbName)\"\r\n".utf8)
            )
            body.append(Data("Content-Type: image/\(ext)\r\n\r\n".utf8))
            body.append(thumbData)
            body.append(Data("\r\n".utf8))
        }
        body.append(Data("--\(boundary)--\r\n".utf8))
        return body
    }

    private func compressedThumbnailData(from url: URL) -> Data? {
        let maxBytes = 1_900_000 // 1.9 MB safety threshold
        guard let image = UIImage(contentsOfFile: url.path) else {
            return try? Data(contentsOf: url)
        }
        var compression: CGFloat = 0.9
        guard var data = image.jpegData(compressionQuality: compression) else { return nil }
        // 🔄 Iteratively compress until it fits under 1.9 MB
        while data.count > maxBytes, compression > 0.1 {
            compression -= 0.15
            if let newData = image.jpegData(compressionQuality: compression) {
                data = newData
            }
        }
        print("📸 Final compressed thumbnail size: \(Double(data.count) / 1_000_000) MB")
        if data.count > 2_000_000 {
            print("⚠️ WARNING: Thumbnail is still over 2MB, Supabase might reject this!")
        }
        return data
    }

    // MARK: - URLSession Delegates

    func urlSession(_: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if responseData[dataTask.taskIdentifier] == nil {
            responseData[dataTask.taskIdentifier] = Data()
        }
        responseData[dataTask.taskIdentifier]?.append(data)
    }

    func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let uploadId = task.taskDescription ?? ""
        let data = responseData[task.taskIdentifier] ?? Data()
        responseData.removeValue(forKey: task.taskIdentifier)

        if let error = error {
            print("❌ Background Upload failed: \(error)")
            return
        }

        if let httpResponse = task.response as? HTTPURLResponse {
            print("✅ Upload HTTP Status: \(httpResponse.statusCode)")
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                // Parse YouTube Video ID from Google's Final Chunk Response
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let videoId = json["id"] as? String {
                    print("✅ Uploaded video ID: \(videoId)")

                    Task {
                        do {
                            try await attachThumbnailToVideo(uploadId: uploadId, videoId: videoId)
                        } catch {
                            print("❌ Failed to orchestrate thumbnail request: \(error)")
                        }
                    }
                } else {
                    print("❌ Could not parse YouTube video ID from Google response")
                    if let stringData = String(data: data, encoding: .utf8) {
                        print("Google Payload: \(stringData)")
                    }
                }
            } else {
                print("❌ Google Recieved Upload fail status \(httpResponse.statusCode)")
                if let stringData = String(data: data, encoding: .utf8) {
                    print("Google Error Payload: \(stringData)")
                }
            }
        }
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession _: URLSession) {
        DispatchQueue.main.async {
            self.backgroundCompletionHandler?()
            self.backgroundCompletionHandler = nil
        }
    }
}
