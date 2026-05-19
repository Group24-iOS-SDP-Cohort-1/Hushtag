import Foundation
import Supabase

final class PreferencesController {

    private let client = SupabaseConfig.client

    func savePreferences(
        dict: [String: [String]]
    ) async throws {

        let session = try await client.auth.session

        let platformMapped = (dict["Platform"] ?? []).map {
            $0 == "x (twitter)" ? "x" : $0
        }

        let payload = PreferenceInsertPayload(
            user_id: session.user.id,
            niche: dict["Niche"] ?? [],
            platform: platformMapped
        )

        try await client.database
            .from("user_preferences")
            .upsert(payload, onConflict: "user_id")
            .execute()
    }

    func fetchPreferences() async throws -> UserPreference {
        let session = try await client.auth.session
        // print("FETCH UID:", session.user.id)

        let preferences: [PreferenceDB] = try await client.database
            .from("user_preferences")
            .select()
            .eq("user_id", value: session.user.id)
            .execute()
            .value

        guard let latest = preferences.first else {
            throw NSError(domain: "No Preferences Found", code: 404)
        }

        return mapToPreference(latest)
    }

    private func mapToPreference(_ preference: PreferenceDB) -> UserPreference {
        UserPreference(
            user_id: preference.user_id,
            niche: preference.niche ?? [],
            platform: preference.platform ?? []
        )
    }
}
