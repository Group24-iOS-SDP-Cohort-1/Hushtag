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
    
    func replaceDeal(_ updatedDeal: Deal) {
        scheduleItems = scheduleItems.map {
            guard case .deal(let deal, let deliverable) = $0,
                  deal.id == updatedDeal.id else {
                return $0
            }
            
            let updatedDeliverable =
            updatedDeal.deliverables.first { $0.id == deliverable.id }
            ?? deliverable
            
            return .deal(deal: updatedDeal, deliverable: updatedDeliverable)
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
