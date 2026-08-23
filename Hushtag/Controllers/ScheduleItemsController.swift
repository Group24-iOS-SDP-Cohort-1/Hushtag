import Foundation

final class ScheduleItemController {
    private let dealsController = DealsController()
    private let youtubeController = YouTubeUploadController()

    private var deals: [Deal] = []
    private var youtubeUploads: [YouTubeUpload] = []

    func replaceDeal(_ updatedDeal: Deal) {
        deals = deals.map {
            $0.id == updatedDeal.id ? updatedDeal : $0
        }
    }

    func getDeal(id: UUID) -> Deal? {
        return deals.first { $0.id == id }
    }

    func load() async throws {
        async let dealsTask = dealsController.fetchDeals()
        async let uploadsTask = youtubeController.fetchUploads()

        do {
            deals = try await dealsTask
        } catch {
            print("Failed to fetch deals: \(error)")
        }

        do {
            youtubeUploads = try await uploadsTask
        } catch {
            print("Failed to fetch youtube uploads: \(error)")
        }
    }

    func scheduleItems(on date: Date) -> [ScheduleItem] {
        let calendar = Calendar.current
        var allItems: [ScheduleItem] = []

        // 1. Process Deals
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

        // 2. Process YouTube Uploads
        for upload in youtubeUploads {
            if calendar.isDate(upload.effectiveDate, inSameDayAs: date) {
                allItems.append(.youtubeUpload(upload: upload))
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
            case let .youtubeUpload(upload):
                return upload.uploadStatus == "completed"
            }
        }
    }
}
