//
//  AuthManager.swift
//  Hushtag
//
//  Created by SDC-USER on 23/01/26.
//

import Foundation
import Supabase



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
        print(session)
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
        print(session)
        print(session.user)
        
        return AppUser(uid: session.user.id.uuidString, email: session.user.email)
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
}
