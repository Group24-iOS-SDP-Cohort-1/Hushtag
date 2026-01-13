//
//  Ideate1.swift
//  Hushtag
//
//  Created by SDC-USER on 17/12/25.
//

import UIKit

class Ideate1: UIViewController {

    var ideaResponse = IdeaResponse()
    var ideas: [Idea] = []
    var selectedIdea: Idea?
    var selectedIndexPath: IndexPath?

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scriptButton: UIButton!
    @IBOutlet weak var scriptView: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        ideas = ideaResponse.ideas
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "IdeaCells", bundle: nil), forCellWithReuseIdentifier: "ideaCell")
        collectionView.register(UINib(nibName: "IdeaSearch", bundle:nil ),forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "IdeaSearch")
        collectionView.register(UINib(nibName: "SuggestedFYHeader", bundle:nil ),forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "suggestedHeader")
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUI), name: .didUpdateLikedStatus, object: nil)
        scriptButton.layer.borderWidth = 1
        scriptButton.layer.borderColor = UIColor.accent.cgColor
    }
    
    @objc func refreshUI() {
        collectionView.reloadData()
    }

    @IBAction func scriptTap(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Chatbot")
            navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func viewScriptTap(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "ViewScripts", bundle: nil)
        guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController else {return}
        guard let destinationVC = navVC.topViewController as? ViewScriptsViewController else {return}
        destinationVC.pageTitle = "Your Scripts"
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }

    @IBAction func viewLikedTap(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "ViewScripts", bundle: nil)
        guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController else {return}
        guard let destinationVC = navVC.topViewController as? ViewScriptsViewController else {return}
        destinationVC.pageTitle = "Liked Ideas"
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }

    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            
            if sectionIndex == 0 {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(1)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(1)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(370)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [header]

                return section
            }

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(112)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(170)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(300)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            section.boundarySupplementaryItems = [header]
            section.interGroupSpacing = 15
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

            return section
        }
    }
    
    func categorizeIdea(engagementRate: Double) -> String {
        if engagementRate >= 20 {
            return "Viral"
        } else if engagementRate >= 10 {
            return "Growing"
        } else {
            return "Niche"
        }
    }
}

extension Ideate1: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
       return  ideas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ideaCell",
            for: indexPath
        ) as! IdeaCells

        let idea = ideas[indexPath.row]
        let engagement = Double(idea.engagementRate) ?? 0.0
        let category = categorizeIdea(engagementRate: engagement)
        let keyword2: EngagementStyle

        switch category {
        case "Viral":
            keyword2 = EngagementStyle(
                text: "Trending",
                icon: "flame",
                color: .systemRed
            )

        case "Growing":
            keyword2 = EngagementStyle(
                text: "Growing",
                icon: "bolt",
                color: .systemOrange
            )

        case "Niche":
            keyword2 = EngagementStyle(
                text: "Niche",
                icon: "bolt",
                color: .systemGreen
            )

        default:
            return cell
        }

        cell.configure(idea: idea, keyword2: keyword2)
        return cell
    }

    func collectionView( _ collectionView: UICollectionView,viewForSupplementaryElementOfKind kind: String,at indexPath: IndexPath
    ) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        if indexPath.section == 0 {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "IdeaSearch",
                for: indexPath
            ) as! IdeaSearch

            header.delegate = self
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "suggestedHeader",
                for: indexPath
            ) as! SuggestedFYHeader
            return header
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        let idea = ideas[indexPath.row]
        let storyboard = UIStoryboard(name: "ViewIdea", bundle: nil)
        guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController else {return}
        guard let destinationVC = navVC.topViewController as? ViewIdea else {return}
        destinationVC.idea = idea
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }

}

extension Ideate1: IdeaSearchDelegate {
    func didTapSearch(with keyword: String) {
        if keyword.isEmpty {
            ideas = ideaResponse.ideas
        } else {
            ideas = ideaResponse.ideas.filter { idea in
                idea.hashtag.contains { tag in
                    tag.localizedCaseInsensitiveContains(keyword)
                }
            }
        }
        collectionView.reloadSections(IndexSet(integer: 1))
    }
}

extension Notification.Name {
    static let didUpdateLikedStatus = Notification.Name("didUpdateLikedStatus")
}
