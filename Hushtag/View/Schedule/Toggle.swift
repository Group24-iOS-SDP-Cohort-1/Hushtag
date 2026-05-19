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

    static func toggleMainPost(
        post: Post,
        postsController: PostsController
    ) async throws -> Post {
        let newValue = !post.isCompleted

        var updatedPost = post
        updatedPost.isManuallyCompleted = newValue
        updatedPost.tasks = post.tasks.map {
            var t = $0
            t.isCompleted = newValue
            return t
        }

        return try await postsController.updatePost(updatedPost)
    }

    static func toggleMainDeal(
        deal: Deal,
        dealsController: DealsController
    ) async throws -> Deal {
        let newValue = !deal.isCompleted

        var updatedDeal = deal
        updatedDeal.isManuallyCompleted = newValue
        updatedDeal.deliverables = deal.deliverables.map {
            var d = $0
            d.isCompleted = newValue
            return d
        }

        return try await dealsController.updateDeal(updatedDeal)
    }
}
