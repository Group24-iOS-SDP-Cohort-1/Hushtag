//
//  AuthService.swift
//  Hushtag
//
//  Created by SDC-USER on 23/01/26.
//

import Supabase

final class AuthService {

    private let client = SupabaseConfig.client

    func signUp(email: String, password: String) async throws {
        try await client.auth.signUp(
            email: email,
            password: password
        )
    }

    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(
            email: email,
            password: password
        )
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func currentUser() async throws -> User {
            let session = try await client.auth.session
            return session.user
        }
}
