//
//  DealsViewController.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class DealsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    // use the instance you already have
    var dealResponse = DealResponse()
    var deals: [Deal] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()

       deals = dealResponse.deals
        print(deals.count)

        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.clipsToBounds = false

    }

    func registerCell() {
        collectionView.register(
            UINib(nibName: "DealsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "deal_cell"
        )
    }

    // MARK: - Layout
    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(160)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(160) // change to .absolute(160) to test fixed height
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 20
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 12, bottom: 20, trailing: 12)

            return section
        }
    }
}

// MARK: - UICollectionViewDataSource
extension DealsViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deals.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "deal_cell", for: indexPath) as! DealsCollectionViewCell

        let deal = deals[indexPath.item]
        cell.configure(with: deal)

        return cell
    }
}
