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
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selected_Deal : Deal?
    var deals: [Deal] = []
    private var isSearching = false
    private var searchText = ""
    
    private let dealsController = DealsController()
    
    var completedDeals: [Deal] {
        deals.filter { $0.isCompleted }
    }
    
    
    var ongoingDeals: [Deal] {
        return deals.filter { !$0.isCompleted }
    }
    private var selectedSegmentIndex = 0
    
    var displayedDeals: [Deal] {
        let baseDeals = selectedSegmentIndex == 0 ? ongoingDeals : completedDeals
        
        guard isSearching, !searchText.isEmpty else {
            return baseDeals
        }
        
        let query = searchText.lowercased()
        
        return baseDeals.filter {
            $0.name.lowercased().contains(query) ||
            $0.email.lowercased().contains(query) ||
            $0.platform.contains(where: {
                $0.rawValue.lowercased().contains(query)
            })
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCell()
        
        // here we are fetching the deals from the data store
        _Concurrency.Task {
            do {
                let session = try await SupabaseConfig.client.auth.session
                print("Logged in UID:", session.user.id)
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
        let grayColor = UIColor.darkGray
        
        // Not selected color appearance
        segmentControl.setTitleTextAttributes([
            .foregroundColor: grayColor,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
        
        // Selected color appearance
        segmentControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
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
                print("Supabase insert failed:")
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
        if let idx = deals.firstIndex(where: { $0.id == deal.id }) {
            deals[idx] = deal
            collectionView.reloadData()
        }
    }
    
    func dealsInfo(_ controller: DealsInfo, didDeleteDeal dealId: UUID) {
        
        if let index = deals.firstIndex(where: { $0.id == dealId }) {
            deals.remove(at: index)
        }
        
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
}


extension DealsViewController: AddDealsDelegate {
    
    func addDealsViewController(
        _ controller: AddDealsViewController,
        didUpdateDeal deal: Deal,
        at index: Int
    ) {
        
        if let realIndex = deals.firstIndex(where: { $0.id == deal.id }) {
            deals[realIndex] = deal
        }
        
        
        selectedSegmentIndex = segmentControl.selectedSegmentIndex
        
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    func addDealsViewController(
        _ controller: AddDealsViewController,
        didCreateDeal deal: Deal
    ) {
        fetchDeals()
    }
}

extension DealsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        isSearching = !searchText.isEmpty
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearching = false
        collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
