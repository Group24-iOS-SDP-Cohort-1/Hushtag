import Foundation
import Supabase

final class DealsController {

    private let client = SupabaseConfig.client

    func addDeal(_ deal: Deal) async throws -> Deal {
        let session = try await client.auth.session

        let payload = DealInsertPayload(
            user_id: session.user.id,
            name: deal.name,
            payment: Double(deal.payment),
            mobileNumber: deal.mobileNumber,
            email: deal.email,
            description: deal.description,
            deadline: deal.deliverables.map(\.deadline).max() ?? Date(),
            platform: deal.platform.joined(separator: ",")
        )

        let dealDB: DealDB = try await client.database
            .from("brand_deals")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value

        let deliverablesPayload = deal.deliverables.map {
            DeliverableDB(
                deal_id: dealDB.id,
                name: $0.name,
                deadline: $0.deadline,
                isCompleted: $0.isCompleted
            )
        }

        let insertedDeliverables: [DeliverableDB] = try await client.database
            .from("deliverables")
            .insert(deliverablesPayload)
            .select()
            .execute()
            .value

        return mapToDeal(dealDB, insertedDeliverables)
    }


    func fetchDeals() async throws -> [Deal] {


        let session = try await client.auth.session
        print("FETCH UID:", session.user.id)

        let deals: [DealDB] = try await client.database
            .from("brand_deals")
            .select()
            .execute()
            .value

        let deliverables: [DeliverableDB] = try await client.database
            .from("deliverables")
            .select()
            .execute()
            .value

        return deals.map { deal in
            mapToDeal(
                deal,
                deliverables.filter { $0.deal_id == deal.id }
            )
        }
    }




    // MAPPER
    private func mapToDeal(
        _ deal: DealDB,
        _ deliverables: [DeliverableDB]
    ) -> Deal {
        Deal(
            id: deal.id,
            name: deal.name,
            payment: deal.payment ?? 0.0,                     // ✅ FIX
            mobileNumber: deal.mobileNumber ?? 0,           // ✅ FIX
            email: deal.email ?? "",                         // ✅ FIX
            description: deal.description ?? "",             // ✅ FIX
            platform: deal.platform
                .split(separator: ",")
                .map { String($0) },
            deliverables: deliverables.map {
                Deliverable(
                    id: $0.deal_id,
                    name: $0.name,
                    deadline: $0.deadline,
                    isCompleted: $0.isCompleted
                )
            }
        )
    }


}
