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
    var dataStore: DataStore = DataStore.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsView.delegate = self
        detailsView.dataSource = self
        detailsView.setCollectionViewLayout(generateLayout(), animated: false)
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
        guard case .post(var post) = schedule,
              var tasks = post.tasks,
              taskIndex < tasks.count else { return }

        tasks[taskIndex].isCompleted = isCompleted
        post.tasks = tasks
        schedule = .post(post)

        dataStore.updatePost(post)

        detailsView.reloadItems(at: [IndexPath(row: taskIndex, section: 1)])
    }
}

extension Details: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        case .deal(let deal):
            if section == 1 {
                return 1
            }
            return deal.deliverables.count

        case .post(let post):
            return post.tasks?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    guard let schedule else { return UICollectionViewCell() }

        switch schedule {
        case .deal(let deal):
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "common_details",
                    for: indexPath
                ) as! DetailsCollectionViewCell
                cell.configureCommon(with: schedule)
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
            cell.applyLiquidGlassEffect()
            return cell
            
            case .post(let post):
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "common_details",
                    for: indexPath
                ) as! DetailsCollectionViewCell
                cell.configureCommon(with: schedule)
                return cell
            }
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "multiple_details",
                for: indexPath
            ) as! DetailsCollectionViewCell

            if let tasks = post.tasks, indexPath.row < tasks.count {
                let task = tasks[indexPath.row]
                cell.configureMultiple(with: task)
                cell.applyLiquidGlassEffect()
            }

            return cell
        }
    }
}
