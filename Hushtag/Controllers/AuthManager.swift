import Foundation
import Supabase
internal import _Helpers

struct AppUser{
    let uid: String
    let email: String?
    var fullName: String? = nil
}

class AuthManager{
    
    static let shared = AuthManager()
    
    private init() {}
    
    
    let client = SupabaseConfig.client
    
    func getCurrentSession() async throws -> AppUser {
        let session = try await client.auth.session
        
        let metadata = session.user.userMetadata
        
        // Extract the full name from the metadata
        let fullName: String?
        if case .string(let name) = metadata["full_name"] {
            fullName = name
        } else {
            fullName = nil
        }
        
        return AppUser(uid: session.user.id.uuidString, email: session.user.email, fullName: fullName)
    }
    
    //New user registration with email id and password
    func registerNewUserWithEmail(email: String, password: String, fullName: String) async throws -> AppUser {
        
        let metadata: [String: AnyJSON] = [
            "full_name": .string(fullName)
        ]
        
        let response = try await client.auth.signUp(email: email, password: password, data: metadata)
        
        guard let session = response.session else {
            throw AuthError.sessionMissing
        }
        
        return AppUser(uid: session.user.id.uuidString, email: session.user.email, fullName: fullName)
    }
    
    
    func signInWithEmail(email: String, password: String) async throws -> AppUser {
        let session = try await client.auth.signIn(email: email, password: password)
        
        let metadata = session.user.userMetadata
        let fullName: String?
        if case .string(let name) = metadata["full_name"] {
            fullName = name
        } else {
            fullName = nil
        }
        
        return AppUser(uid: session.user.id.uuidString, email: session.user.email, fullName: fullName)
    }
    
    
    func signInWithGoogle(idToken: String) async throws -> AppUser {
        let session = try await client.auth.signInWithIdToken(credentials: .init(provider: .google, idToken: idToken))
        
        let metadata = session.user.userMetadata
        let fullName: String?
        if case .string(let name) = metadata["full_name"] {
            fullName = name
        } else {
            fullName = nil
        }
        
        return AppUser(uid: session.user.id.uuidString, email: session.user.email, fullName: fullName)
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    
    
    
    
    func hasCompletedOnboarding() async -> Bool {
        
        guard let session = try? await client.auth.session else { return false }
        
        let metadata = session.user.userMetadata
        
        guard let jsonValue = metadata["onboarding_completed"] else {
            return false
        }
        
        if jsonValue == .bool(true) {
            return true
        }
        
        return false
    }
    
    
    func completeOnboarding() async throws {
        let attributes = UserAttributes(data: ["onboarding_completed": .bool(true)])
        let _ = try await client.auth.update(user: attributes)
    }
    
    func updateFullName(newName: String) async throws {
        let attributes = UserAttributes(data: ["full_name": .string(newName)])
        let _ = try await client.auth.update(user: attributes)
    }
}
