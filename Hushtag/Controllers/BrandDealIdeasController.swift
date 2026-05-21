import Foundation
import Supabase

final class BrandDealIdeasController {
    private let client = SupabaseConfig.client

    /// Fetches all deal mappings for a specific scripted idea.
    func fetchDealsForScript(scriptedIdeaId: UUID) async throws -> [BrandDealIdea] {
        let session = try await client.auth.session

        return try await client.database
            .from("brand_deal_ideas")
            .select()
            .eq("userId", value: session.user.id)
            .eq("scriptedIdeaId", value: scriptedIdeaId)
            .execute()
            .value
    }

    /// Inserts a mapping between a deal and a scripted idea.
    func tagDealToScript(dealId: UUID, scriptedIdeaId: UUID) async throws {
        let session = try await client.auth.session

        let payload = BrandDealIdea(
            userId: session.user.id,
            dealId: dealId,
            scriptedIdeaId: scriptedIdeaId,
            createdAt: nil // Let Supabase set the default
        )

        try await client.database
            .from("brand_deal_ideas")
            .insert(payload)
            .execute()
    }

    /// Deletes a mapping between a deal and a scripted idea.
    func untagDealFromScript(dealId: UUID, scriptedIdeaId: UUID) async throws {
        let session = try await client.auth.session

        try await client.database
            .from("brand_deal_ideas")
            .delete()
            .eq("userId", value: session.user.id)
            .eq("dealId", value: dealId)
            .eq("scriptedIdeaId", value: scriptedIdeaId)
            .execute()
    }

    /// Fetches all script mappings for a specific deal.
    func fetchScriptsForDeal(dealId: UUID) async throws -> [BrandDealIdea] {
        let session = try await client.auth.session

        return try await client.database
            .from("brand_deal_ideas")
            .select()
            .eq("userId", value: session.user.id)
            .eq("dealId", value: dealId)
            .execute()
            .value
    }
}
