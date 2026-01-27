import Foundation
import Supabase

final class DealsController {

    private let client = SupabaseConfig.client

    func addDeal(_ deal: Deal) async throws -> Deal {
        let session = try await client.auth.session

        let payload = DealDB(
            user_id: session.user.id,
            name: deal.name,
            payment: deal.payment,
            mobileNumber: deal.mobileNumber,
            email: deal.email,
            description: deal.description,
            deadline: deal.deliverables.map(\.deadline).max() ?? Date(),
            platform: deal.platform.joined(separator: ","),
            isCompleted: false
        )

        let dealDB: DealDB = try await client.database
            .from("brand_deals")
            .insert(payload)
            .select()
            .execute()
            .value

        let deliverablesPayload = deal.deliverables.map {
            DeliverableDB(
                id: UUID(),
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
            .eq("user_id", value: session.user.id)
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

    private func mapToDeal(
        _ deal: DealDB,
        _ deliverables: [DeliverableDB]
    ) -> Deal {
        Deal(
            id: deal.id,
            name: deal.name,
            payment: deal.payment ?? 0.0,
            mobileNumber: deal.mobileNumber ?? 0,
            email: deal.email ?? "",
            description: deal.description ?? "",             
            platform: deal.platform
                .split(separator: ",")
                .map { String($0) },
            deliverables: deliverables.map {
                Deliverable(
                    id: $0.id,
                    name: $0.name,
                    deadline: $0.deadline,
                    isCompleted: $0.isCompleted
                )
            } 
        )
    }
}
