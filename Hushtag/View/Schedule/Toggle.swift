import Foundation

enum ToggleService {
    static func toggleTask(
        post: Post,
        task: Tasks,
        postsController: PostsController
    ) async throws -> Post {
        let newValue = !task.isCompleted

        var updatedPost = post
        updatedPost.tasks = post.tasks.map {
            var currentTask = $0
            if currentTask.id == task.id {
                currentTask.isCompleted = newValue
            }
            return currentTask
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
            var currentDeliverable = $0
            if currentDeliverable.id == deliverable.id {
                currentDeliverable.isCompleted = newValue
            }
            return currentDeliverable
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
            var currentTask = $0
            currentTask.isCompleted = newValue
            return currentTask
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
            var currentDeliverable = $0
            currentDeliverable.isCompleted = newValue
            return currentDeliverable
        }

        return try await dealsController.updateDeal(updatedDeal)
    }
}
