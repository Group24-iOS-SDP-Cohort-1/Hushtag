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
                .map { ScheduleItem.deal(deal: deal, deliverable: $0) }
                .filter {
                    calendar.isDate($0.effectiveDeadline, inSameDayAs: date)
                }
        }
        
        let postItems = posts.flatMap { post in
            post.tasks
                .map { ScheduleItem.post(post: post, task: $0) }
                .filter {
                    calendar.isDate($0.effectiveDeadline, inSameDayAs: date)
                }
        }
        
        return (dealItems + postItems)
            .sorted { $0.effectiveDeadline < $1.effectiveDeadline }
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
