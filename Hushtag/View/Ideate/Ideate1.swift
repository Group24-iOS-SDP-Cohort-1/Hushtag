//
//  Ideate1.swift
//  Hushtag
//
//  Created by SDC-USER on 17/12/25.
//

import UIKit

class Ideate1: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var ideaResponse = IdeaResponse()
    var ideas: [Idea] = []
    var selectedIdea: Idea?
    var selectedIndexPath: IndexPath?

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

    }

    @IBAction func scriptTap(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Chatbot")
            navigationController?.pushViewController(vc, animated: true)
        

    }

    @IBAction func viewScriptTap(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "ViewScripts", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "viewScripts")
//            navigationController?.pushViewController(vc, animated: true)
//        vc.title = "Your Scripts"
        guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController else {return}
        guard let destinationVC = navVC.topViewController as? ViewScriptsViewController else {return}
        destinationVC.pageTitle = "Your Scripts"
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
                heightDimension: .estimated(170)
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
            section.interGroupSpacing = 10
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
            
        let keyword1: EngagementStyle
        let keyword2: EngagementStyle

        switch category {
        case "Viral":
            keyword2 = EngagementStyle(
                text: "Trending",
                icon: "flame",
                color: .systemRed
            )
            keyword1 = EngagementStyle(
                text: "Beginner",
                icon: "chart.bar",
                color: .systemGreen
            )

        case "Growing":
            keyword2 = EngagementStyle(
                text: "Growing",
                icon: "bolt",
                color: .systemOrange
            )
            keyword1 = EngagementStyle(
                text: "Easy",
                icon: "chart.bar",
                color: .systemGreen
            )

        case "Niche":
            keyword2 = EngagementStyle(
                text: "Niche",
                icon: "bolt",
                color: .systemGreen
            )
            keyword1 = EngagementStyle(
                text: "Medium",
                icon: "chart.bar",
                color: .systemOrange
            )

        default:
            return cell
        }

        cell.configure(idea: idea, keyword1: keyword1, keyword2: keyword2)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToScript" {
            let vc = segue.destination as! ScriptedIdeas
            vc.idea = selectedIdea
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        selectedIdea = ideas[indexPath.row]
        performSegue(withIdentifier: "goToScript", sender: nil)
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
