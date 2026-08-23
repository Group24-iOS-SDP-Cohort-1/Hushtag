import UIKit

extension Schedule {
    func handleDeliverableToggle(deal: Deal, deliverable: Deliverable) async {
        let optimisticDeal: Deal = {
            var copy = deal
            copy.deliverables = deal.deliverables.map {
                var deliverableItem = $0
                if deliverableItem.id == deliverable.id {
                    deliverableItem.isCompleted.toggle()
                }
                return deliverableItem
            }
            return copy
        }()

        scheduleController.replaceDeal(optimisticDeal)
        filterItems(for: selectedDate)

        await MainActor.run {
            scheduleView.reloadSections(IndexSet(integer: 1))
        }

        do {
            let savedDeal = try await ToggleService.toggleDeliverable(
                deal: deal,
                deliverable: deliverable,
                dealsController: dealsController
            )

            scheduleController.replaceDeal(savedDeal)
            filterItems(for: selectedDate)

            await MainActor.run {
                scheduleView.reloadSections(IndexSet(integer: 1))
                NotificationCenter.default.post(name: .dealsDidChange, object: nil)
            }
        } catch {
            scheduleController.replaceDeal(deal)
            filterItems(for: selectedDate)

            await MainActor.run {
                scheduleView.reloadSections(IndexSet(integer: 1))
            }
        }
    }

    func handleMainDealToggle(deal: Deal) async {
        let optimisticDeal: Deal = {
            var copy = deal
            copy.isManuallyCompleted.toggle()
            let newStatus = copy.isManuallyCompleted
            copy.deliverables = copy.deliverables.map {
                var deliverableItem = $0
                deliverableItem.isCompleted = newStatus
                return deliverableItem
            }
            return copy
        }()

        scheduleController.replaceDeal(optimisticDeal)
        filterItems(for: selectedDate)

        await MainActor.run {
            scheduleView.reloadSections(IndexSet(integer: 1))
        }

        do {
            let savedDeal = try await ToggleService.toggleMainDeal(
                deal: deal,
                dealsController: dealsController
            )

            scheduleController.replaceDeal(savedDeal)
            filterItems(for: selectedDate)

            await MainActor.run {
                scheduleView.reloadSections(IndexSet(integer: 1))
                NotificationCenter.default.post(name: .dealsDidChange, object: nil)
            }
        } catch {
            scheduleController.replaceDeal(deal)
            filterItems(for: selectedDate)

            await MainActor.run {
                scheduleView.reloadSections(IndexSet(integer: 1))
            }
        }
    }
}
