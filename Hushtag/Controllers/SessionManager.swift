import Foundation
import Supabase
import Combine

class SessionManager: ObservableObject {
    
    static let shared = SessionManager()
    private init() {}
    
    @Published var currentUser: AppUser?
    @Published var userPreferences: UserPreference?
    
    @Published var personalizedIdeas: [Idea] = []
    
    func restoreSession() async {
        do {
            let user = try await AuthManager.shared.getCurrentSession()
            self.currentUser = user
            
            await fetchPreferences()
            await preloadIdeas()
            
        } catch {
            print("No active session:", error)
        }
    }
    
    private func fetchPreferences() async {
        do {
            let prefs = try await PreferencesController().fetchPreferences()
            
            await MainActor.run {
                self.userPreferences = prefs
                print("Preferences loaded:", prefs)
            }
            
        } catch {
            print("❌ Failed to fetch preferences:", error)
        }
    }
    
    func preloadIdeas() async {
        
        guard let prefs = userPreferences else {
            print("❌ No prefs found")
            return
        }
        
        let selectedTopics = Array(prefs.niche.prefix(3))
        var loadedIdeas: [Idea] = []
        
        for topic in selectedTopics {
            
            do {
                let response = try await YouTubeService().search(query: topic.rawValue)
                
                // Pick first cluster
                guard let firstCluster = response.clusterIdeas.first else {
                    continue
                }
                
                // Pick first Gemini idea from that cluster
                guard let firstIdea = firstCluster.ideas.first else {
                    continue
                }
                
                // Map first 3 videos from that cluster
                let mappedVideos: [Video] = firstCluster.videos
                    .prefix(3)
                    .map { $0.toVideo() }

                let key = makeIdeaKey(
                    title: firstIdea.title,
                    description: firstIdea.description,
                    format: firstIdea.format,
                    hashtags: firstIdea.hashtags
                )

                // Build final Idea
                loadedIdeas.append(
                    Idea(
                        id: UUID(),
                        ideaKey: key,
                        title: firstIdea.title,
                        description: firstIdea.description,
                        format: firstIdea.format,
                        hashtags: firstIdea.hashtags,
                        noveltyScore: firstIdea.noveltyScore,
                        videos: mappedVideos,
                        liked: false
                    )
                )
                
            } catch {
                print("❌ Failed topic \(topic):", error)
            }
        }
        
        await MainActor.run {
            self.personalizedIdeas = loadedIdeas
            print("✅ Preloaded ideas:", loadedIdeas.count)
        }
    }
    
    func clearSession() {
        currentUser = nil
        userPreferences = nil
    }
}
