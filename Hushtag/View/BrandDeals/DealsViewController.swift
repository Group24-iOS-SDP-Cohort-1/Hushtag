//
//  DealsViewController.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class DealsViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!

    
   var selected_Deal : Deal?
    var dealResponse = DealResponse()
    var deals: [Deal] = []
    var completedDeals: [Deal] {
            return deals.filter {
                let total = $0.deliverable.count
                let completed = $0.deliverable.filter { $0.isCompleted }.count
                return total > 0 && completed == total
            }
        }

     
        var ongoingDeals: [Deal] {
            return deals.filter {
                let total = $0.deliverable.count
                let completed = $0.deliverable.filter { $0.isCompleted }.count
                return completed != total
            }
        }
    private var selectedSegmentIndex = 0

        // deals that the collection view should show for current tab
        var displayedDeals: [Deal] {
            return selectedSegmentIndex == 0 ? ongoingDeals : completedDeals
        }

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()

       deals = dealResponse.deals
        print(deals.count)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
//        collectionView.clipsToBounds = false
        
        segmentControl.selectedSegmentIndex = 0
        
        selectedSegmentIndex = 0
        let purpleColor = UIColor(red: 139/255, green: 92/255, blue: 246/255, alpha: 1)
        let grayColor = UIColor.darkGray

        // Normal (not selected)
        segmentControl.setTitleTextAttributes([
            .foregroundColor: grayColor,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)

        // Selected
        segmentControl.setTitleTextAttributes([
            .foregroundColor: purpleColor,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)

    }

    @IBAction func segmentedAction(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
            collectionView.reloadData()
    }
    
    func registerCell() {
        collectionView.register(
            UINib(nibName: "DealsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ongoing_deal_cell"
        )
        collectionView.register(
            UINib(nibName: "CompletedDealsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "completed_deal_cell"
        )
    }

    // MARK: - Layout
    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(200)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(200) // change to .absolute(160) to test fixed height
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 7.5
            section.contentInsets = NSDirectionalEdgeInsets(top: 7.5, leading: 0, bottom: 7.5, trailing: 0)

            return section
        }
    }
}

extension DealsViewController: UICollectionViewDataSource ,UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return displayedDeals.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let deal = displayedDeals[indexPath.item]

        if selectedSegmentIndex == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ongoing_deal_cell",
                for: indexPath
            ) as! DealsCollectionViewCell

            cell.configure(with: deal)
            cell.onTap = { [weak self] in
                self?.performSegue(withIdentifier: "info_page", sender: deal)
            }
            return cell

        } else {
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "completed_deal_cell",
                for: indexPath
            ) as! CompletedDealsCollectionViewCell

            cell.configure(with: deal)
//            cell.onTap = { [weak self] in
//                       self?.performSegue(withIdentifier: "info_page", sender: deal)
//                   }
            return cell
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "info_page",
           let deal = sender as? Deal,
           let vc = segue.destination as? DealsInfo {
            
            vc.deals = deal  // ⭐ pass data here
            if let ideaId = deal.selectedIdeaIndex {
                let ideaResponse = IdeaResponse()
                vc.selectedIdea = ideaResponse.ideas.first { $0.id == ideaId }
            } else {
                vc.selectedIdea = nil}
        }
    }
}
