import Foundation

final class ScheduleItemController {
    private let dealsController = DealsController()
    private let postsController = PostsController()

    private var deals: [Deal] = []
    private var posts: [Post] = []

    func replacePost(_ updatedPost: Post) {
        posts = posts.map {
            $0.id == updatedPost.id ? updatedPost : $0
        }
    }

    func replaceDeal(_ updatedDeal: Deal) {
        deals = deals.map {
            $0.id == updatedDeal.id ? updatedDeal : $0
        }
    }

    func getPost(id: UUID?) -> Post? {
        return posts.first { $0.id == id }
    }

    func getDeal(id: UUID) -> Deal? {
        return deals.first { $0.id == id }
    }

    func load() async throws {
        async let dealsTask = dealsController.fetchDeals()
        async let postsTask = postsController.fetchPosts()

        deals = try await dealsTask
        posts = try await postsTask
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

        // 2. Process Posts
        for post in posts {
            // Include main post if deadline matches
            if calendar.isDate(
                post.deadline,
                inSameDayAs: date
            ) {
                allItems.append(.post(post: post, task: nil))
            }

            // Include individual tasks if their deadline matches
            for task in post.tasks where calendar.isDate(task.deadline, inSameDayAs: date) {
                allItems.append(.post(post: post, task: task))
            }
        }

        return allItems.sorted { $0.effectiveDeadline < $1.effectiveDeadline }
    }

    func completedScheduleItems(on date: Date) -> [ScheduleItem] {
        scheduleItems(on: date).filter { item in
            switch item {
            case let .deal(deal, deliverable):
                // If it's a deliverable, use its completion status. If it's the main deal, use the deal's completion
                // status.
                return deliverable?.isCompleted ?? deal.isManuallyCompleted
            case let .post(_, task):
                // If it's a task, use its status. If it's the main post, just return false (unless you add an
                // isCompleted flag to Post)
                return task?.isCompleted ?? false
            }
        }
    }
}
