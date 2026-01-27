import Foundation

final class ScheduleItemController {

    private let dealsController = DealsController()
    private let postsController = PostsController()

    private var deals: [Deal] = []
    private var posts: [Post] = []

    func load() async throws {
        async let dealsTask = dealsController.fetchDeals()
        async let postsTask = postsController.fetchPosts()

        self.deals = try await dealsTask
        self.posts = try await postsTask
    }

    func scheduleItems(on date: Date) -> [ScheduleItem] {
        let calendar = Calendar.current

        let dealItems = deals.flatMap { deal in
            deal.deliverables
                .filter { calendar.isDate($0.deadline, inSameDayAs: date) }
                .map { ScheduleItem.deal(deal: deal, deliverable: $0) }
        }

        let postItems = posts.flatMap { post in
            post.tasks
                .filter { calendar.isDate($0.deadline, inSameDayAs: date) }
                .map { ScheduleItem.post(post: post, task: $0) }
        }

        return (dealItems + postItems)
            .sorted { $0.date < $1.date }
    }

    func completedScheduleItems(on date: Date) -> [ScheduleItem] {
        scheduleItems(on: date).filter { $0.isCompleted }
    }
}
