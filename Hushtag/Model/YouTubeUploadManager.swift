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
    func uploadVideo(
        videoURL: URL,
        thumbnailURL: URL?,
        title: String,
        description: String?,
        tags: [String]?,
        categoryId: String,
        privacyStatus: String,
        publishAt: Date?
    ) {
        Task {
            do {
                // 1. Copy video to Documents directory for robust background networking compliance
                let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let persistentVideoURL = documentsDir.appendingPathComponent(videoURL.lastPathComponent)

                if FileManager.default.fileExists(atPath: persistentVideoURL.path) {
                    try? FileManager.default.removeItem(at: persistentVideoURL)
                }
                try FileManager.default.copyItem(at: videoURL, to: persistentVideoURL)

                // 4. Fetch JWT and manually construct multipart handshake
                let session = try await SupabaseConfig.client.auth.session
                let jwtToken = session.accessToken
                print("🔑 RAW JWT: \(jwtToken)")
                let boundary = "Boundary-\(UUID().uuidString)"

                let urlString = "https://juuuwuydlgjhgwwabswy.supabase.co/functions/v1/youtube-upload"
                var request = URLRequest(url: URL(string: urlString)!)
                request.httpMethod = "POST"
                request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
                await request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

                // 5. Assemble Multipart Data
                let isoFormatter = ISO8601DateFormatter()
                let finalPrivacy = publishAt != nil ? "private" : privacyStatus.lowercased()

                let parameters: [String: String] = [
                    "title": title,
                    "description": description ?? "",
                    "tags": tags != nil ? "[\(tags!.map { "\"\($0)\"" }.joined(separator: ","))]" : "[]",
                    "categoryId": categoryId,
                    "privacyStatus": finalPrivacy,
                    "publishAt": publishAt != nil ? isoFormatter.string(from: publishAt!) : "",
                    "localVideoFilename": persistentVideoURL.lastPathComponent
                ]

                var body = buildMultipartBody(
                    parameters: parameters,
                    thumbnailURL: thumbnailURL,
                    boundary: boundary
                )

                request.httpBody = body

                // 7. Fire Handshake to Edge Function
                let (responseData, responseURL) = try await URLSession.shared.data(for: request)

                guard let httpResponse = responseURL as? HTTPURLResponse else {
                    print("Invalid response from handshake")
                    return
                }

                if !(200 ... 299).contains(httpResponse.statusCode) {
                    if let errString = String(data: responseData, encoding: .utf8) {
                        print("❌ Handshake failed (\(httpResponse.statusCode)): \(errString)")
                    } else {
                        print("❌ Handshake failed with status code: \(httpResponse.statusCode)")
                    }
                    return
                }

                let resumableData = try JSONDecoder().decode(GetResumableUrlResponse.self, from: responseData)

                guard let uploadUrl = URL(string: resumableData.resumableUploadUrl) else {
                    print("Invalid Resumable URL returned from backend")
                    return
                }

                // 6. Start Native Background Video Upload
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

                    // Call Edge Function to finalize thumbnail attachment via Supabase
                    // Call Edge Function to finalize thumbnail attachment via Supabase
                    Task {
                        do {
                            // 1. Get a fresh auth token
                            let session = try await SupabaseConfig.client.auth.session
                            let jwtToken = session.accessToken

                            // 2. Use the hardcoded production URL (Matching the exact spelling of your function)
                            let urlString = "https://juuuwuydlgjhgwwabswy.supabase.co/functions/v1/set-youtube-thumbnail"
                            var request = URLRequest(url: URL(string: urlString)!)
                            request.httpMethod = "POST"

                            // 3. Set standard Supabase headers
                            request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
                            await request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
                            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                            // 4. Encode your existing struct into the body
                            let reqBody = AttachThumbnailRequest(uploadId: uploadId, youtubeVideoId: videoId)
                            request.httpBody = try JSONEncoder().encode(reqBody)

                            // 5. Fire the request
                            let (data, response) = try await URLSession.shared.data(for: request)

                            if let httpResponse = response as? HTTPURLResponse {
                                if (200 ... 299).contains(httpResponse.statusCode) {
                                    print("✅ Thumbnail attachment and DB update triggered successfully!")
                                } else {
                                    let errStr = String(data: data, encoding: .utf8) ?? "Unknown"
                                    print("❌ Thumbnail Edge Function failed (\(httpResponse.statusCode)): \(errStr)")
                                }
                            }
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
