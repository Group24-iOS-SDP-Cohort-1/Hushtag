//
//  DealsViewController.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit
import PostgREST
import Supabase
class DealsViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!


    
    var selected_Deal : Deal?
    var deals: [Deal] = []
    private let dealsController = DealsController()

    var completedDeals: [Deal] {
        deals.filter {
            let total = $0.deliverables.count
            let completed = $0.deliverables.filter { $0.isCompleted }.count
            return total > 0 && completed == total
        }
    }

     
        var ongoingDeals: [Deal] {
            return deals.filter {
                let total = $0.deliverables.count
                let completed = $0.deliverables.filter { $0.isCompleted }.count
                return total > 0 && completed != total
            }
        }
    private var selectedSegmentIndex = 0

        // deals for current tab in segmented control
        var displayedDeals: [Deal] {
            return selectedSegmentIndex == 0 ? ongoingDeals : completedDeals
        }

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCell()

        // here we are fetching the deals from the data store
        _Concurrency.Task {
                     do {
                         let session = try await SupabaseConfig.client.auth.session
                         print("✅ Logged in UID:", session.user.id)
                         print("SESSION ACCESS TOKEN:", session.accessToken.prefix(20))

                     } catch {
                         print("❌ No auth session:", error)
              }
          }

       



        fetchDeals()

        print(deals.count)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        segmentControl.selectedSegmentIndex = 0
        
        selectedSegmentIndex = 0
        let purpleColor = UIColor(red: 139/255, green: 92/255, blue: 246/255, alpha: 1)
        let grayColor = UIColor.darkGray

        // Not selected color appearance
        segmentControl.setTitleTextAttributes([
            .foregroundColor: grayColor,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)

        // Selected color appearance
        segmentControl.setTitleTextAttributes([
            .foregroundColor: purpleColor,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)


    }

    @IBAction func segmentedAction(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
            
            // set the generateLayout function for the collection view
            collectionView.setCollectionViewLayout(generateLayout(), animated: false)
            
            collectionView.reloadData()
    }

    private func fetchDeals()  {
        _Concurrency.Task {
            do {
                let fetchedDeals = try await dealsController.fetchDeals()

                await MainActor.run {
                    self.deals = fetchedDeals
                    self.selectedSegmentIndex = self.segmentControl.selectedSegmentIndex
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    self.collectionView.reloadData()
                }

            } catch {
                print("❌ Supabase insert failed:")
                dump(error)
            }

            }

        }



    func registerCell() {
        collectionView.register(
            UINib(nibName: "DealsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ongoing_deal_cell"
        )
    }

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
            section.interGroupSpacing = 15
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 0,
                bottom: 0,
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

        // on tap is a closure for performing the segue
        
        cell.onTap = { [weak self] in
            self?.performSegue(withIdentifier: "info_page", sender: deal)
        }

        return cell
    }
    
    // prepare function for navigation and data passing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController,
               let addVC = nav.viewControllers.first as? AddDealsViewController {
                addVC.delegate = self
            } else if let addVC = segue.destination as? AddDealsViewController {
                addVC.delegate = self
            }
        // this will send the data
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
            
            // this is for tag deals stuff
//            if let ideaId = deal.selectedIdeaIndex {
//                let ideaResponse = IdeaResponse()
//                vc.selectedIdea = ideaResponse.ideas.first { $0.id == ideaId }
//            } else {
//                vc.selectedIdea = nil
//            }
        }
    }
}


// this is for if we perform complete operation inside the deals info
extension DealsViewController: DealsInfoDelegate {
    func dealsInfo(_ controller: DealsInfo, didUpdateDeal deal: Deal, at index: Int) {
        guard index >= 0 && index < deals.count else { return }
        deals[index] = deal
        collectionView.reloadData()
    }
}

//this is for if we add new deals using the modal
extension DealsViewController: AddDealsDelegate {
    func addDealsViewController(_ controller: AddDealsViewController, didCreateDeal deal: Deal) {
        fetchDeals()
        deals.insert(deal, at: 0)
        collectionView.reloadData()
    }
}
