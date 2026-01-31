import Foundation
import Supabase

final class ProfileController {

    private let client = SupabaseConfig.client

    // MARK: - Fetch Profile
    func fetchProfile() async throws -> Profile {

        let session = try await client.auth.session

        let profileDB: ProfileDB = try await client.database
            .from("profiles")
            .select()
            .eq("id", value: session.user.id)
            .single()
            .execute()
            .value

        return mapToProfile(profileDB)
    }

    // MARK: - Update Profile
    func updateProfile(
        fullName: String,
        avatarURL: String?
    ) async throws -> Profile {

        let session = try await client.auth.session

        let payload = ProfileUpdatePayload(
            full_name: fullName,
            avatar_url: avatarURL
        )

        let updatedProfile: ProfileDB = try await client.database
            .from("profiles")
            .update(payload)
            .eq("id", value: session.user.id)
            .select()
            .single()
            .execute()
            .value

        return mapToProfile(updatedProfile)
    }

    // MARK: - Mapper (Deals-style)
    private func mapToProfile(_ db: ProfileDB) -> Profile {
        Profile(
            id: db.id,
            fullName: db.full_name,
            email: db.email,
            avatarURL: db.avatar_url
        )
    }
}
