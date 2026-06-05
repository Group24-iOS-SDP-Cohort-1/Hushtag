import UIKit

class Details: UIViewController {
    @IBOutlet var detailsView: UICollectionView!
    var schedule: ScheduleItem?
    var onToggleTask: ((Post, Tasks) -> Void)?
    var onToggleMainPost: ((Post) -> Void)?
    var onToggleDeliverable: ((Deal, Deliverable) -> Void)?
    var onToggleMainDeal: ((Deal) -> Void)?
    let postsController = PostsController()
    let dealsController = DealsController()

    override func viewDidLoad() {
        super.viewDidLoad()
        detailsView.dataSource = self
        detailsView.setCollectionViewLayout(generateLayout(), animated: false)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePostsDidChange),
            name: .postsDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDealsDidChange),
            name: .dealsDidChange,
            object: nil
        )
    }

    /// In Details.swift
    @objc private func handlePostsDidChange() {
        Task {
            do {
                let posts = try await postsController.fetchPosts()
                if case let .post(currentPost, currentTask) = self.schedule {
                    if let updatedPost = posts.first(where: { $0.id == currentPost.id }) {
                        // CHANGED: Safely handle if currentTask is nil
                        let updatedTask = currentTask != nil ?
                            (updatedPost.tasks.first(where: { $0.id == currentTask!.id }) ?? currentTask) : nil

                        await MainActor.run {
                            self.schedule = .post(post: updatedPost, task: updatedTask)
                            self.detailsView.reloadData()
                        }
                    }
                }
            } catch {
                print("Failed to fetch posts: \(error)")
            }
        }
    }

    @objc private func handleDealsDidChange() {
        Task {
            do {
                let deals = try await dealsController.fetchDeals()
                if case let .deal(currentDeal, currentDeliverable) = self.schedule {
                    if let updatedDeal = deals.first(where: { $0.id == currentDeal.id }) {
                        // CHANGED: Safely handle if currentDeliverable is nil
                        let updatedDeliverable = currentDeliverable != nil ?
                            (updatedDeal.deliverables
                                .first(where: { $0.id == currentDeliverable!.id }) ?? currentDeliverable) : nil

                        await MainActor.run {
                            self.schedule = .deal(deal: updatedDeal, deliverable: updatedDeliverable)
                            self.detailsView.reloadData()
                        }
                    }
                }
            } catch {
                print("Failed to fetch deals: \(error)")
            }
        }
    }

    func generateLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] section, _ in
            guard let self, let schedule = self.schedule else { return nil }

            if case .deal = schedule, section == 0 || section == 1 {
                return self.dealLayoutSection()
            }

            if case .post = schedule, section == 0 {
                return self.postLayoutSection()
            }

            return self.defaultLayoutSection()
        }
    }

    private func dealLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(0.9),
                heightDimension: .estimated(90)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        return section
    }

    private func postLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
        item.contentInsets = .init(top: 2, leading: 7, bottom: 2, trailing: 7)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(0.9),
                heightDimension: .estimated(120)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 10, leading: 20, bottom: 10, trailing: 20)
        return section
    }

    private func defaultLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
        item.contentInsets = .init(top: 7, leading: 7, bottom: 7, trailing: 7)

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(100)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        return section
    }

    private func updateTaskCompletion(taskIndex: Int, isCompleted: Bool) {
        guard case var .post(post, _) = schedule,
              taskIndex < post.tasks.count else { return }

        post.tasks[taskIndex].isCompleted = isCompleted
        schedule = .post(post: post, task: post.tasks[taskIndex])

        detailsView.reloadItems(at: [IndexPath(row: taskIndex, section: 1)])
    }

    func performDelete(postId: UUID) {
        Task {
            do {
                try await postsController.deletePost(postId: postId)

                // Notify Schedule to reload
                NotificationCenter.default.post(
                    name: .postsDidChange,
                    object: nil
                )

                await MainActor.run {
                    self.dismiss(animated: true)
                }

            } catch {
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Failed to Delete",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    func performDelete(dealId: UUID) {
        Task {
            do {
                try await dealsController.deleteDeal(dealId)

                // Notify Schedule to reload
                NotificationCenter.default.post(
                    name: .dealsDidChange,
                    object: nil
                )

                await MainActor.run {
                    self.dismiss(animated: true)
                }

            } catch {
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Failed to Delete",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    func handleTaskToggle(post: Post, task: Tasks) async {
        onToggleTask?(post, task)
    }

    func handleMainPostToggle(post: Post) async {
        onToggleMainPost?(post)
    }

    func handleDeliverableToggle(deal: Deal, deliverable: Deliverable) async {
        onToggleDeliverable?(deal, deliverable)
    }

    func handleMainDealToggle(deal: Deal) async {
        onToggleMainDeal?(deal)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "editDeal" {
            if let nav = segue.destination as? UINavigationController,
               let dest = nav.topViewController as? AddDealsViewController,
               case let .deal(deal, _) = schedule {
                dest.editingDeal = deal
                dest.editingIndex = 0
                dest.delegate = self
            } else if let dest = segue.destination as? AddDealsViewController,
                      case let .deal(deal, _) = schedule {
                dest.editingDeal = deal
                dest.editingIndex = 0
                dest.delegate = self
            }
        }
    }
}
