import Foundation
import Supabase
internal import _Helpers

struct AppUser{
    let uid: String
    let email: String?
}

class AuthManager{
    
    static let shared = AuthManager()
    
    private init() {}
    
    
    let client = SupabaseConfig.client
    
    func getCurrentSession() async throws -> AppUser {
        let session = try await client.auth.session
        return AppUser(uid: session.user.id.uuidString, email: session.user.email)
    }
    
    
    //    func registerNewUserWithEmail(email: String, password: String) async throws -> AppUser {
    //        let regAuthResponse = try await client.auth.signUp(email: email, password: password)
    //        guard let session = regAuthResponse.session else {
    //            print("no session when registering user")
    //            throw NSError()
    //        }
    //        return AppUser(uid: session.user.id.uuidString, email: session.user.email)
    //    }
    
    func registerNewUserWithEmail(email: String, password: String) async throws -> AppUser {
        let response = try await client.auth.signUp(email: email, password: password)
        
        guard let session = response.session else {
            throw AuthError.sessionMissing
        }
        
        return AppUser(uid: session.user.id.uuidString, email: session.user.email)
    }
    
    
    func signInWithEmail(email: String, password: String) async throws -> AppUser {
        let session = try await client.auth.signIn(email: email, password: password)
        
        return AppUser(uid: session.user.id.uuidString, email: session.user.email)
    }
    
    
    func signInWithGoogle(idToken: String) async throws -> AppUser {
        let session = try await client.auth.signInWithIdToken(credentials: .init(provider: .google, idToken: idToken))
        return AppUser(uid: session.user.id.uuidString, email: session.user.email)
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    
    
    
    // MARK: - Onboarding Logic
    
    func hasCompletedOnboarding() async -> Bool {
        // 1. Get Session
        guard let session = try? await client.auth.session else { return false }
        
        // 2. Get Metadata
        let metadata = session.user.userMetadata
        
        // 3. Check if key exists
        guard let jsonValue = metadata["onboarding_completed"] else {
            return false
        }
        
        // 4. THE FIX: Direct comparison using '=='
        // This avoids the 'let binding' error entirely.
        if jsonValue == .bool(true) {
            return true
        }
        
        return false
    }
    
    
    func completeOnboarding() async throws {
        // Use .bool explicitly so the compiler knows it's AnyJSON
        let attributes = UserAttributes(data: ["onboarding_completed": .bool(true)])
        let _ = try await client.auth.update(user: attributes)
    }
    
}
