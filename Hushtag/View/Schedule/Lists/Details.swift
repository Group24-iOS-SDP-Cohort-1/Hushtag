//
//  Details.swift
//  Hushtag
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit

class Details: UIViewController {
    
    @IBOutlet weak var detailsView: UICollectionView!
    var schedule: ScheduleItem?
    var onToggleTask: ((Post, Tasks) -> Void)?
    var onToggleMainPost: ((Post) -> Void)?
    var onToggleDeliverable: ((Deal, Deliverable) -> Void)?
    var onToggleMainDeal: ((Deal) -> Void)?
    private let postsController = PostsController()
    private let dealsController = DealsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsView.dataSource = self
        detailsView.setCollectionViewLayout(generateLayout(), animated: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePostsDidChange), name: .postsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDealsDidChange), name: .dealsDidChange, object: nil)
    }
    
    // In Details.swift
        @objc private func handlePostsDidChange() {
            Task {
                do {
                    let posts = try await postsController.fetchPosts()
                    if case .post(let currentPost, let currentTask) = self.schedule {
                        if let updatedPost = posts.first(where: { $0.id == currentPost.id }) {
                            
                            // CHANGED: Safely handle if currentTask is nil
                            let updatedTask = currentTask != nil ? (updatedPost.tasks.first(where: { $0.id == currentTask!.id }) ?? currentTask) : nil
                            
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
                    if case .deal(let currentDeal, let currentDeliverable) = self.schedule {
                        if let updatedDeal = deals.first(where: { $0.id == currentDeal.id }) {
                            
                            // CHANGED: Safely handle if currentDeliverable is nil
                            let updatedDeliverable = currentDeliverable != nil ? (updatedDeal.deliverables.first(where: { $0.id == currentDeliverable!.id }) ?? currentDeliverable) : nil
                            
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
            
            // Sections 0 & 1 are horizontal cards for DEAL
            if case .deal = schedule, (section == 0 || section == 1) {
                
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
            
            // Section 0 is horizontal card for POST
            if case .post = schedule, section == 0 {
                
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
            
            // Everything else → vertical list / grid
            // Everything else → vertical list / grid
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
    }
    
    private func updateTaskCompletion(taskIndex: Int, isCompleted: Bool) {
        guard case .post(var post, _) = schedule,
              taskIndex < post.tasks.count else { return }
        
        post.tasks[taskIndex].isCompleted = isCompleted
        schedule = .post(post: post, task: post.tasks[taskIndex])
        
        detailsView.reloadItems(at: [IndexPath(row: taskIndex, section: 1)])
    }
    
    private func performDelete(postId: UUID) {
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
    
    private func performDelete(dealId: UUID) {
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
    
    private func handleTaskToggle(post: Post, task: Tasks) async {
        onToggleTask?(post, task)
    }
    
    private func handleMainPostToggle(post: Post) async {
        onToggleMainPost?(post)
    }
    
    private func handleDeliverableToggle(deal: Deal, deliverable: Deliverable) async {
        onToggleDeliverable?(deal, deliverable)
    }
    
    private func handleMainDealToggle(deal: Deal) async {
        onToggleMainDeal?(deal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "editPost" {
                if let nav = segue.destination as? UINavigationController,
                   let dest = nav.topViewController as? AddViewController,
                   case .post(let post, _) = schedule {
                    dest.editingPost = post
                    dest.editingIndex = 0 // Ensures the delegate method triggers
                    dest.delegate = self
                } else if let dest = segue.destination as? AddViewController,
                          case .post(let post, _) = schedule {
                    dest.editingPost = post
                    dest.editingIndex = 0
                    dest.delegate = self
                }
            } else if segue.identifier == "editDeal" {
                if let nav = segue.destination as? UINavigationController,
                   let dest = nav.topViewController as? AddDealsViewController,
                   case .deal(let deal, _) = schedule {
                    dest.editingDeal = deal
                    dest.editingIndex = 0
                    dest.delegate = self
                } else if let dest = segue.destination as? AddDealsViewController,
                          case .deal(let deal, _) = schedule {
                    dest.editingDeal = deal
                    dest.editingIndex = 0
                    dest.delegate = self
                }
            }
        }
    
}

extension Details: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch schedule {
        case .deal:
            return 3
        case .post:
            return 2
        default:
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let schedule else { return 0 }
        
        if section == 0 {
            return 1
        }
        switch schedule {
        case .deal(let deal, _):
            if section == 1 {
                return 1
            }
            return deal.deliverables.count
            
        case .post(let post, _):
            return post.tasks.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let schedule = schedule else {
            return UICollectionViewCell()
        }
        
        switch schedule {
        case .deal(let deal, _):
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "common_details",
                    for: indexPath
                ) as! DetailsCollectionViewCell
                cell.indexPath = indexPath
                // Add Main Toggle action directly on common_details cell. We can just use the status/circle button if it existed, but usually Section 0 does not have a status button. If it does, here's how to toggle it.
                cell.onToggleCompletion = { [weak self] _ in
                    guard let self else { return }
                    guard case .deal(let deal, _) = self.schedule else { return }
                    
                    Task {
                        await self.handleMainDealToggle(deal: deal)
                    }
                }
                
                cell.configureCommon(with: schedule)
                cell.onDeleteTapped = { [weak self] in
                    guard let self else { return }
                    
                    DispatchQueue.main.async {
                        let alert = UIAlertController(
                            title: "Delete Deal?",
                            message: "This will permanently delete the deal and all its deliverables.",
                            preferredStyle: .alert
                        )
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                            guard case .deal(let deal, _) = self.schedule else { return }
                            let dealId = deal.id
                            self.performDelete(dealId: dealId)
                        })
                        
                        self.topMostViewController.present(alert, animated: true)
                    }
                }
                cell.onEditTapped = { [weak self] in
                    self?.performSegue(withIdentifier: "editDeal", sender: self)
                }
                
                return cell
            }
            
            if indexPath.section == 1 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "deal_details",
                    for: indexPath
                ) as! DetailsCollectionViewCell
                cell.DealDetails(with: deal)
                
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "multiple_details",
                for: indexPath
            ) as! DetailsCollectionViewCell
            
            let deliverable = deal.deliverables[indexPath.row]
            cell.indexPath = indexPath
            cell.configureMultiple(with: deliverable)
            cell.onToggleCompletion = { [weak self] indexPath in
                guard let self else { return }
                guard case .deal(let deal, _) = self.schedule else { return }
                
                let deliverable = deal.deliverables[indexPath.row]
                
                Task {
                    await self.handleDeliverableToggle(
                        deal: deal,
                        deliverable: deliverable
                    )
                }
            }
            
            
            cell.applyLiquidGlassEffect()
            return cell
            
        case .post(let post, _):
            
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "common_details",
                    for: indexPath
                ) as! DetailsCollectionViewCell
                cell.indexPath = indexPath
                // Add Main Toggle action directly on common_details cell for Post.
                cell.onToggleCompletion = { [weak self] _ in
                    guard let self else { return }
                    guard case .post(let post, _) = self.schedule else { return }
                    
                    Task {
                        await self.handleMainPostToggle(post: post)
                    }
                }
                
                cell.configureCommon(with: schedule)
                cell.onDeleteTapped = { [weak self] in
                    guard let self else { return }
                    
                    DispatchQueue.main.async {
                        let alert = UIAlertController(
                            title: "Delete Post?",
                            message: "This will permanently delete the post and all its tasks.",
                            preferredStyle: .alert
                        )
                        
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                            guard case .post(let post, _) = self.schedule,
                                  let postId = post.id else { return }
                            self.performDelete(postId: postId)
                        })
                        
                        self.topMostViewController.present(alert, animated: true)
                    }
                }
                cell.onEditTapped = { [weak self] in
                    self?.performSegue(withIdentifier: "editPost", sender: self)
                }
                
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "multiple_details",
                for: indexPath
            ) as! DetailsCollectionViewCell
            
            let task = post.tasks[indexPath.row]
            cell.indexPath = indexPath
            cell.configureMultiple(with: task)
            cell.onToggleCompletion = { [weak self] indexPath in
                guard let self else { return }
                guard case .post(let post, _) = self.schedule else { return }
                
                let task = post.tasks[indexPath.row]
                
                Task {
                    await self.handleTaskToggle(post: post, task: task)
                }
            }
            
            
            cell.applyLiquidGlassEffect()
            
            return cell
            
        }
    }
    
}

extension UIViewController {
    
    var topMostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController
        }
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController ?? tab
        }
        return self
    }
}

// MARK: - Delegate Extensions for Instant UI Updates
extension Details: AddViewDelegate {
    func addViewController(_ controller: AddViewController, didCreatePost post: Post) { }
    
    func addViewController(_ controller: AddViewController, didUpdatePost post: Post, at index: Int) {
        guard case .post(_, let currentTask) = self.schedule else { return }
        
        // CHANGED: Handle optional task
        let updatedTask = currentTask != nil ? (post.tasks.first(where: { $0.id == currentTask!.id }) ?? currentTask) : nil
        
        self.schedule = .post(post: post, task: updatedTask)
        self.detailsView.reloadData()
    }
}

extension Details: AddDealsDelegate {
    func addDealsViewController(_ controller: AddDealsViewController, didCreateDeal deal: Deal) { }
    
    func addDealsViewController(_ controller: AddDealsViewController, didUpdateDeal deal: Deal, at index: Int) {
        guard case .deal(_, let currentDeliverable) = self.schedule else { return }
        
        // CHANGED: Handle optional deliverable
        let updatedDeliverable = currentDeliverable != nil ? (deal.deliverables.first(where: { $0.id == currentDeliverable!.id }) ?? currentDeliverable) : nil
        
        self.schedule = .deal(deal: deal, deliverable: updatedDeliverable)
        self.detailsView.reloadData()
    }
}
