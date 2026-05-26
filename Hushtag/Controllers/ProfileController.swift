import Foundation
import Supabase

final class ProfileController {
    private let client = SupabaseConfig.client

    func fetchProfile() async throws -> Profile {
        let session = try await client.auth.session

        let profileDB: ProfileDB = try await client.database
            .from("profiles")
            .select()
            .eq("userId", value: session.user.id)
            .single()
            .execute()
            .value

        return mapToProfile(profileDB)
    }

    func updateProfile(
        fullName: String,
        avatarURL: String?
    ) async throws -> Profile {
        let session = try await client.auth.session

        let payload = ProfileUpdatePayload(
            fullName: fullName,
            avatarUrl: avatarURL
        )

        let updated: [ProfileDB] = try await client.database
            .from("profiles")
            .update(payload)
            .eq("userId", value: session.user.id)
            .select()
            .execute()
            .value

        guard let profile = updated.first else {
            throw NSError(domain: "ProfileUpdate", code: 0)
        }

        return mapToProfile(profile)
    }

    private func mapToProfile(_ profileDB: ProfileDB) -> Profile {
        Profile(
            id: profileDB.userId,
            fullName: profileDB.fullName,
            email: profileDB.email,
            avatarURL: profileDB.avatarUrl,
            isYouTubeConnected: profileDB.isYoutubeConnected ?? false
        )
    }
}
