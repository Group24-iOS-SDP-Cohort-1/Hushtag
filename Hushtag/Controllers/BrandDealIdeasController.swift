import Foundation
import Supabase

final class BrandDealIdeasController {

    private let client = SupabaseConfig.client

    /// Fetches all deal mappings for a specific scripted idea.
    func fetchDealsForScript(scriptedIdeaId: UUID) async throws -> [BrandDealIdea] {
        let session = try await client.auth.session

        let mappings: [BrandDealIdea] = try await client.database
            .from("brand_deal_ideas")
            .select()
            .eq("user_id", value: session.user.id)
            .eq("scripted_idea_id", value: scriptedIdeaId)
            .execute()
            .value

        return mappings
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
            .eq("user_id", value: session.user.id)
            .eq("deal_id", value: dealId)
            .eq("scripted_idea_id", value: scriptedIdeaId)
            .execute()
    }

    /// Fetches all script mappings for a specific deal.
    func fetchScriptsForDeal(dealId: UUID) async throws -> [BrandDealIdea] {
        let session = try await client.auth.session

        let mappings: [BrandDealIdea] = try await client.database
            .from("brand_deal_ideas")
            .select()
            .eq("user_id", value: session.user.id)
            .eq("deal_id", value: dealId)
            .execute()
            .value

        return mappings
    }
}
