import Foundation
import Supabase
import Combine
import UIKit

class SessionManager: ObservableObject {
    
    static let shared = SessionManager()
    private init() {}
    
    @Published var currentUser: AppUser?
    @Published var userPreferences: UserPreference?
    
    @Published var personalizedIdeas: [Idea] = []
    
    var currentProfile: Profile?
    var profileImageCache: UIImage?
    
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
        
        // Take top 3 niches
        let selectedTopics = Array(prefs.niche.prefix(3))
        let clusterStrings = selectedTopics.map { $0.rawValue }
        
        print("🚀 Fetching ideas for:", clusterStrings)
        
        do {
            // Wrap completion API into async/await
            let bundles: [ClusterIdea] = try await withCheckedThrowingContinuation { continuation in
                
                SupabaseEdgeService.shared.fetchClusterIdeas(clusters: clusterStrings) { result in
                    switch result {
                        
                    case .success(let bundles):
                        continuation.resume(returning: bundles)
                        
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            // Convert bundles → Ideas
            let loadedIdeas: [Idea] = bundles.map { bundle in
                
                let generatedKey = makeIdeaKey(
                    title: bundle.idea.title,
                    description: bundle.idea.description,
                    format: bundle.idea.format,
                    hashtags: bundle.idea.hashtags
                )
                
                return Idea(
                    id: bundle.idea.id,
                    ideaKey: bundle.idea.ideaKey ?? generatedKey,
                    title: bundle.idea.title,
                    description: bundle.idea.description,
                    format: bundle.idea.format,
                    hashtags: bundle.idea.hashtags,
                    noveltyScore: bundle.idea.noveltyScore,
                    videos: bundle.idea.videos,
                    expandedDescription: nil,
                    liked: false
                )
            }
            
            // Update UI safely
            await MainActor.run {
                self.personalizedIdeas = loadedIdeas
                print("✅ Preloaded ideas from Edge Function:", loadedIdeas.count)
            }
            
        } catch {
            print("❌ Failed to preload ideas:", error)
        }
    }
    
    
    func clearSession() {
        currentUser = nil
        userPreferences = nil
        currentProfile = nil
        profileImageCache = nil
    }
    
    func refreshProfileAndAvatar(with profile: Profile, image: UIImage?) {
        self.currentProfile = profile
        if let image = image {
            self.profileImageCache = image
        }
        NotificationCenter.default.post(name: .didUpdateProfile, object: nil)
    }
    
    func getProfileAndAvatar(forceRefresh: Bool = false) async throws -> (Profile, UIImage?) {
        if !forceRefresh, let profile = currentProfile {
            return (profile, profileImageCache)
        }
        
        let profile = try await ProfileController().fetchProfile()
        self.currentProfile = profile
        
        if let urlString = profile.avatarURL, let url = URL(string: urlString) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                self.profileImageCache = UIImage(data: data)
            } catch {
                print("Failed to load avatar image data:", error)
            }
        } else {
            self.profileImageCache = nil
        }
        
        return (profile, self.profileImageCache)
    }
}

extension Notification.Name {
    static let didUpdateProfile = Notification.Name("didUpdateProfile")
}
