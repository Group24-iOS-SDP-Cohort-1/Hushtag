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
    var keywords: [[String]] = [
        ["Viral Potential", "flame"],
        ["High Impact", "bolt"],
        ["Massive Reach", "antenna.radiowaves.left.and.right"],
        ["Explosive Growth", "exclamationmark.triangle.fill"],
        ["Game Changer", "star.fill"],
        ["Maximum Engagement", "hand.raised.fill"],
        ["Instant Virality", "bolt.circle.fill"],
        ["Wide Appeal", "eye.fill"],
        ["Buzz-Worthy", "speaker.wave.3.fill"],
        ["Unstoppable Momentum", "arrow.2.circlepath"],
        ["Rapid Exposure", "hourglass.tophalf.fill"],
        ["Trendsetting", "flame.fill"],
        ["Audience Magnet", "person.3.fill"],
        ["Share-Worthy", "square.and.arrow.up.fill"],
        ["Limitless Potential", "infinity.circle.fill"],
        ["Next-Level Influence", "arrow.up.right.circle.fill"],
        ["Unmatched Reach", "wifi.circle.fill"],
        ["Powerful Results", "target"],
        ["High ROI", "chart.bar.fill"],
        ["Rapid Growth", "gauge"]
    ]


    override func viewDidLoad() {
        super.viewDidLoad()
        ideas = ideaResponse.ideas

        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "IdeaCells", bundle: nil), forCellWithReuseIdentifier: "ideaCell")
        collectionView.register(UINib(nibName: "IdeaSearch", bundle:nil ),forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "IdeaSearch")
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
                    heightDimension: .estimated(300)
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
            section.interGroupSpacing = 10
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

            return section
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
        let keyword1 = keywords[indexPath.row]
        let keyword2 = keywords[indexPath.row + 1]
        cell.configure(idea: idea, keyword1: keyword1, keyword2: keyword2)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader, indexPath.section == 0 else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "IdeaSearch",
            for: indexPath
        ) as! IdeaSearch

        return header
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

