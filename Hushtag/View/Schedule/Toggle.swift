import Foundation

final class ToggleService {
    
    static func toggleTask(
        post: Post,
        task: Tasks,
        postsController: PostsController
    ) async throws -> Post {
        
        let newValue = !task.isCompleted
        
        var updatedPost = post
        updatedPost.tasks = post.tasks.map {
            var t = $0
            if t.id == task.id {
                t.isCompleted = newValue
            }
            return t
        }
        
        try await postsController.updateTaskCompletion(
            taskId: task.id,
            isCompleted: newValue
        )
        
        return updatedPost
    }
    
    static func toggleDeliverable(
        deal: Deal,
        deliverable: Deliverable,
        dealsController: DealsController
    ) async throws -> Deal {
        
        let newValue = !deliverable.isCompleted
        
        var updatedDeal = deal
        updatedDeal.deliverables = deal.deliverables.map {
            var d = $0
            if d.id == deliverable.id {
                d.isCompleted = newValue
            }
            return d
        }
        
        return try await dealsController.updateDeal(updatedDeal)
    }
}
