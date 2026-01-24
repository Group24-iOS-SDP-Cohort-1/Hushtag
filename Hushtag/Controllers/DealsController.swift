import Foundation
import Supabase

final class DealsController {

    private let client = SupabaseConfig.client

    func addDeal(_ deal: Deal) async throws -> Deal {

        let dealDeadline =
            deal.deliverables.map { $0.deadline }.max() ?? Date()

        let dealPayload = DealInsertPayload(
            name: deal.name,
            payment: Double(deal.payment),
            mobileNumber: deal.phone,
            email: deal.email,
            description: deal.description,
            deadline: dealDeadline,
            platform: deal.platform.joined(separator: ",")
        )

        let dealResponse: DealDB = try await client.database
            .from("brand_deals")
            .insert(dealPayload)
            .select()
            .single()
            .execute()
            .value

        let dealId = dealResponse.id


        let deliverablesPayload = deal.deliverables.map {
            DeliverableDB(
                deal_id: dealId,
                name: $0.name,
                deadline: $0.deadline,
                isCompleted: $0.isCompleted
            )
        }

        try await client.database
            .from("deliverables")
            .insert(deliverablesPayload)
            .execute()

        return Deal(
            id: dealId,
            name: deal.name,
            deliverables: deal.deliverables,
            platform: deal.platform,
            phone: deal.phone,
            email: deal.email,
            description: deal.description,
            payment: deal.payment
        )
    }


    func fetchDeals() async throws -> [Deal] {

        let dealsDB: [DealDB] = try await client.database
            .from("brand_deals")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value

        let deliverablesDB: [DeliverableDB] = try await client.database
            .from("deliverables")
            .select()
            .execute()
            .value

        return dealsDB.map { deal in
            Deal(
                id: deal.id,
                name: deal.name,
                deliverables: deliverablesDB
                    .filter { $0.deal_id == deal.id }
                    .map {
                        Deliverable(
                            name: $0.name,
                            deadline: $0.deadline,
                            isCompleted: $0.isCompleted
                        )
                    },
                platform: deal.platform
                    .split(separator: ",")
                    .map(String.init),
                phone: deal.mobileNumber ?? "",
                email: deal.email ?? "",
                description: deal.description ?? "",
                payment: Int(deal.payment)
            )
        }
    }
}
