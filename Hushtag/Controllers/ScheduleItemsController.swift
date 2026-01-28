import Foundation

final class ScheduleItemController {

    private let dealsController = DealsController()
    private let postsController = PostsController()

    private var deals: [Deal] = []
    private var posts: [Post] = []

    private(set) var scheduleItems: [ScheduleItem] = []

    func replacePost(_ updatedPost: Post) {
        scheduleItems = scheduleItems.map {
            guard case .post(let post, let task) = $0,
                  post.id == updatedPost.id else {
                return $0
            }

            let updatedTask = updatedPost.tasks.first { $0.id == task.id } ?? task
            return .post(post: updatedPost, task: updatedTask)
        }
    }
    
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
        scheduleItems(on: date).filter { item in
            switch item {
            case .deal(_, let deliverable):
                return deliverable.isCompleted
            case .post(_, let task):
                return task.isCompleted
            }
        }
    }
}
