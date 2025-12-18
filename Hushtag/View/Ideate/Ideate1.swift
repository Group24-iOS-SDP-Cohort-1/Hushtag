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
    override func viewDidLoad() {
        super.viewDidLoad()
        ideas = ideaResponse.ideas

        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.dataSource = self
        //collectionView.delegate = self
        collectionView.register(UINib(nibName: "IdeaCells", bundle: nil), forCellWithReuseIdentifier: "ideaCells")
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
                heightDimension: .estimated(200)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(200)
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

extension Ideate1: UICollectionViewDataSource {

        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 2
        }

        func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int {

            if section == 0 {
                return 0
            }

           return  ideas.count
        }

        func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ideaCells",
                for: indexPath
            ) as! IdeaCells

            let idea = ideas[indexPath.row]
            cell.configure(idea: idea)
            return cell
        }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader,
              indexPath.section == 0 else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "IdeaSearch",
            for: indexPath
        ) as! IdeaSearch

        return header
    }



}

