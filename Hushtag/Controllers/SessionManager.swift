import Foundation
import Supabase

class SessionManager {
    
    static let shared = SessionManager()
    private init() {}
    
    var currentUser: AppUser?
    var userPreferences: UserPreference?
    
    func restoreSession() async {
        do {
            let user = try await AuthManager.shared.getCurrentSession()
            self.currentUser = user
            
            await fetchPreferences()
            
        } catch {
            print("No active session:", error)
        }
    }
    
    private func fetchPreferences() async {
        do {
            let prefs = try await PreferencesController().fetchPreferences()
            
            DispatchQueue.main.async {
                self.userPreferences = prefs
                print("✅ Preferences loaded:", prefs)
            }
            
        } catch {
            print("❌ Failed to fetch preferences:", error)
        }
    }
    
    func clearSession() {
        currentUser = nil
        userPreferences = nil
    }
}
