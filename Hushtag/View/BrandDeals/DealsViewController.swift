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
            
            // update layout for new tab (different estimated height)
            collectionView.setCollectionViewLayout(generateLayout(), animated: false)
            
            collectionView.reloadData()
    }
    
    func registerCell() {
        collectionView.register(
            UINib(nibName: "DealsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ongoing_deal_cell"
        )
    }

    // MARK: - Layout
    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] _, _ in

            // 0 = Ongoing, 1 = Completed
            let isCompleted = (self?.selectedSegmentIndex == 1)

            let estimatedHeight: CGFloat = isCompleted ? 100 : 200

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(estimatedHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(estimatedHeight)
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 7.5
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 7.5,
                leading: 0,
                bottom: 7.5,
                trailing: 0
            )
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
        let isCompletedTab = (selectedSegmentIndex == 1)

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ongoing_deal_cell",
            for: indexPath
        ) as! DealsCollectionViewCell

        cell.configure(with: deal, isCompleted: isCompletedTab)

        cell.onTap = { [weak self] in
            self?.performSegue(withIdentifier: "info_page", sender: deal)
        }

        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController,
               let addVC = nav.viewControllers.first as? AddDealsViewController {
                addVC.delegate = self
            } else if let addVC = segue.destination as? AddDealsViewController {
                addVC.delegate = self
            }
        if segue.identifier == "info_page",
           let deal = sender as? Deal,
           let vc = segue.destination as? DealsInfo {

            vc.deals = deal

            // find index in the current deals array
            if let idx = deals.firstIndex(where: { $0.id == deal.id }) {
                vc.dealIndex = idx
                vc.delegate = self
            } else {
                vc.dealIndex = -1
            }

            if let ideaId = deal.selectedIdeaIndex {
                let ideaResponse = IdeaResponse()
                vc.selectedIdea = ideaResponse.ideas.first { $0.id == ideaId }
            } else {
                vc.selectedIdea = nil
            }
        }
    }
}


extension DealsViewController: DealsInfoDelegate {
    func dealsInfo(_ controller: DealsInfo, didUpdateDeal deal: Deal, at index: Int) {
        guard index >= 0 && index < deals.count else { return }
        deals[index] = deal
        collectionView.reloadData()
    }
}
extension DealsViewController: AddDealsDelegate {
    func addDealsViewController(_ controller: AddDealsViewController, didCreateDeal deal: Deal) {
        DispatchQueue.main.async {
            self.deals.append(deal)
            self.collectionView.reloadData()
        }
    }
}
