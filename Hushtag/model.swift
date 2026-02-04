import Foundation
import Combine

@MainActor
final class VideoViewModel: ObservableObject {

    @Published var videos: [VideoDTO] = []

    func load() {
        Task {
            do {
                let result = try await YouTubeService()
                    .search(query: "startup")

                self.videos = result
                print("Fetched videos:", result) // 👈 SEE RESULT HERE

            } catch {
                print("Error:", error)
            }
        }
    }

}
