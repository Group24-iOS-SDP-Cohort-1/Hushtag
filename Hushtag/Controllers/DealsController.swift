import Foundation
import Supabase

final class DealsController {
    
    private let client = SupabaseConfig.client
    
    func addDeal(_ deal: Deal) async throws -> Deal {
        let session = try await client.auth.session
        
        let payload = DealInsertPayload(
            user_id: session.user.id,
            name: deal.name,
            payment: deal.payment,
            mobileNumber: deal.mobileNumber,
            email: deal.email,
            deadline: deal.deliverables.map(\.deadline).max() ?? Date(),
            reminder: deal.reminder,
            platform: deal.platform.map(\.rawValue)
        )
        
        let dealDB: DealDB = try await client.database
            .from("brand_deals")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value
        
        var insertedDeliverables: [DeliverableDB] = []
        
        if !deal.deliverables.isEmpty {
            let deliverablesPayload = deal.deliverables.map {
                DeliverableDB(
                    id: UUID(),
                    deal_id: dealDB.id,
                    name: $0.name,
                    deadline: $0.deadline,
                    isCompleted: $0.isCompleted
                )
            }
            
            
            insertedDeliverables = try await client.database
                .from("deliverables")
                .insert(deliverablesPayload)
                .select()
                .execute()
                .value
        }
        
        return mapToDeal(dealDB, insertedDeliverables)
    }
    
    
    func fetchDeals() async throws -> [Deal] {
        
        
        let session = try await client.auth.session
        print("FETCH UID:", session.user.id)
        
        let deals: [DealDB] = try await client.database
            .from("brand_deals")
            .select()
            .eq("user_id", value: session.user.id)
            .order("deadline", ascending: true)
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
    
    func updateDeal(_ deal: Deal) async throws -> Deal {
        let session = try await client.auth.session
        
        let payload = DealInsertPayload(
            user_id: session.user.id,
            name: deal.name,
            payment: deal.payment,
            mobileNumber: deal.mobileNumber,
            email: deal.email,
            deadline: deal.deliverables.map(\.deadline).max() ?? Date(),
            reminder: deal.reminder,
            platform: deal.platform.map(\.rawValue)
        )
        
        let updatedDeal: DealDB = try await client.database
            .from("brand_deals")
            .update(payload)
            .eq("id", value: deal.id)
            .select()
            .single()
            .execute()
            .value
        
        
        try await client.database
            .from("deliverables")
            .delete()
            .eq("deal_id", value: deal.id)
            .execute()
        
        
        let deliverablesPayload = deal.deliverables.map {
            DeliverableDB(
                id:UUID(),
                deal_id: deal.id,
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
        
        return mapToDeal(updatedDeal, insertedDeliverables)
    }
    
    func updateDeliverableStatus(
        deliverableId: UUID,
        isCompleted: Bool
    ) async throws {
        
        try await client.database
            .from("deliverables")
            .update([
                "isCompleted": isCompleted
            ])
            .eq("id", value: deliverableId)
            .execute()
    }
    
    
    func deleteDeal(_ dealId: UUID) async throws {
        
        let session = try await client.auth.session
        
        try await client.database
            .from("deliverables")
            .delete()
            .eq("deal_id", value: dealId)
            .execute()
        
        try await client.database
            .from("brand_deals")
            .delete()
            .eq("id", value: dealId)
            .eq("user_id", value: session.user.id)
            .execute()
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
            
            platform: deal.platform,
            deliverables: deliverables.map {
                Deliverable(
                    id: $0.id,
                    deal_id: $0.deal_id,
                    name: $0.name,
                    deadline: $0.deadline,
                    isCompleted: $0.isCompleted
                )
            },
            reminder: deal.reminder ?? []
        )
    }
}
