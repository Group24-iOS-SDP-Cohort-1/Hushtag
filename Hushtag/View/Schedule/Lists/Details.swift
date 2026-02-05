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
    var onToggleDeliverable: ((Deal, Deliverable) -> Void)?
    private let postsController = PostsController()
    private let dealsController = DealsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsView.dataSource = self
        detailsView.setCollectionViewLayout(generateLayout(), animated: false)
    }
    
//    @objc private func handlePostsDidChange() {
//        Task {
//            try await scheduleController.load()
//
//            await MainActor.run {
//                self.filterItems(for: self.selectedDate)
//                self.scheduleView.reloadSections(IndexSet(integer: 1))
//            }
//        }
//    }
//
//    @objc private func handleDealsDidChange() {
//        Task {
//            try await scheduleController.load()
//
//            await MainActor.run {
//                self.filterItems(for: self.selectedDate)
//                self.scheduleView.reloadSections(IndexSet(integer: 1))
//            }
//        }
//    }

    
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
    
    private func handleDeliverableToggle(deal: Deal, deliverable: Deliverable) async {
        onToggleDeliverable?(deal, deliverable)
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
