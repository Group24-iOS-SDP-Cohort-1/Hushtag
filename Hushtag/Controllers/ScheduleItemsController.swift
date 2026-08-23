import Foundation

final class ScheduleItemController {
    private let dealsController = DealsController()

    private var deals: [Deal] = []

    func replaceDeal(_ updatedDeal: Deal) {
        deals = deals.map {
            $0.id == updatedDeal.id ? updatedDeal : $0
        }
    }

    func getDeal(id: UUID) -> Deal? {
        return deals.first { $0.id == id }
    }

    func load() async throws {
        deals = try await dealsController.fetchDeals()
    }

    func scheduleItems(on date: Date) -> [ScheduleItem] {
        let calendar = Calendar.current
        var allItems: [ScheduleItem] = []

        // Process Deals
        for deal in deals {
            // Include main deal if deadline matches
            if calendar.isDate(deal.deadline, inSameDayAs: date) {
                allItems.append(.deal(deal: deal, deliverable: nil))
            }

            // Include individual deliverables if their deadline matches
            for deliverable in deal.deliverables where calendar.isDate(
                deliverable.deadline,
                inSameDayAs: date
            ) {
                allItems.append(.deal(deal: deal, deliverable: deliverable))
            }
        }

        return allItems.sorted { $0.effectiveDeadline < $1.effectiveDeadline }
    }

    func completedScheduleItems(on date: Date) -> [ScheduleItem] {
        scheduleItems(on: date).filter { item in
            switch item {
            case let .deal(deal, deliverable):
                // If it's a deliverable, use its completion status. If it's the main deal, use the deal's completion status.
                return deliverable?.isCompleted ?? deal.isManuallyCompleted
            }
        }
    }
}
