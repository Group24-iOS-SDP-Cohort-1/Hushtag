import UIKit

extension Schedule {
    func handleTaskToggle(post: Post, task: Tasks) async {
        let optimisticPost: Post = {
            var copy = post
            copy.tasks = post.tasks.map {
                var taskItem = $0
                if taskItem.id == task.id {
                    taskItem.isCompleted.toggle()
                }
                return taskItem
            }
            return copy
        }()

        scheduleController.replacePost(optimisticPost)
        filterItems(for: selectedDate)

        await MainActor.run {
            scheduleView.reloadSections(IndexSet(integer: 1))
        }

        do {
            let savedPost = try await ToggleService.toggleTask(
                post: post,
                task: task,
                postsController: postsController
            )

            scheduleController.replacePost(savedPost)
            filterItems(for: selectedDate)

            await MainActor.run {
                scheduleView.reloadSections(IndexSet(integer: 1))
            }
        } catch {
            scheduleController.replacePost(post)
            filterItems(for: selectedDate)

            await MainActor.run {
                scheduleView.reloadSections(IndexSet(integer: 1))
            }
        }
    }

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
            }
        } catch {
            scheduleController.replaceDeal(deal)
            filterItems(for: selectedDate)

            await MainActor.run {
                scheduleView.reloadSections(IndexSet(integer: 1))
            }
        }
    }

    func handleMainPostToggle(post: Post) async {
        let optimisticPost: Post = {
            var copy = post
            copy.isManuallyCompleted.toggle()
            let newStatus = copy.isManuallyCompleted
            copy.tasks = copy.tasks.map {
                var taskItem = $0
                taskItem.isCompleted = newStatus
                return taskItem
            }
            return copy
        }()

        scheduleController.replacePost(optimisticPost)
        filterItems(for: selectedDate)

        await MainActor.run {
            scheduleView.reloadSections(IndexSet(integer: 1))
        }

        do {
            let savedPost = try await ToggleService.toggleMainPost(
                post: post,
                postsController: postsController
            )

            scheduleController.replacePost(savedPost)
            filterItems(for: selectedDate)

            await MainActor.run {
                scheduleView.reloadSections(IndexSet(integer: 1))
            }
        } catch {
            scheduleController.replacePost(post)
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
