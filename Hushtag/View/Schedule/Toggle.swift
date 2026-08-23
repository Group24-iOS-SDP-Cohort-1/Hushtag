import Foundation

enum ToggleService {
    static func toggleDeliverable(
        deal: Deal,
        deliverable: Deliverable,
        dealsController: DealsController
    ) async throws -> Deal {
        let newValue = !deliverable.isCompleted

        var updatedDeal = deal
        updatedDeal.deliverables = deal.deliverables.map {
            var currentDeliverable = $0
            if currentDeliverable.id == deliverable.id {
                currentDeliverable.isCompleted = newValue
            }
            return currentDeliverable
        }

        return try await dealsController.updateDeal(updatedDeal)
    }

    static func toggleMainDeal(
        deal: Deal,
        dealsController: DealsController
    ) async throws -> Deal {
        let newValue = !deal.isCompleted

        var updatedDeal = deal
        updatedDeal.isManuallyCompleted = newValue
        updatedDeal.deliverables = deal.deliverables.map {
            var currentDeliverable = $0
            currentDeliverable.isCompleted = newValue
            return currentDeliverable
        }

        return try await dealsController.updateDeal(updatedDeal)
    }
}
