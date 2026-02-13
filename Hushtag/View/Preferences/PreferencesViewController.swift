//
//  PreferencesViewController.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit
import SafariServices


//MARK: NEW ADDITION
protocol PreferenceCardSelectionDelegate: AnyObject {
    /// index: which top-level card (0..n-1). isCompleted: whether the card is considered completed now.
    func preferenceCard(at index: Int, didChangeCompletion isCompleted: Bool)
    func preferenceCard(
        at key: String,
        didUpdateSelection selections: [String]
    )
    
    func openURL(_ url: URL)
}


class PreferencesViewController: UIViewController {
    
    
    
    @IBOutlet weak var preferencesCollectionView: UICollectionView!
    
    @IBOutlet weak var progessBarOutlet: UIProgressView!
    
    @IBOutlet weak var pageControlOutlet: UIPageControl!
    
    @IBOutlet weak var skipSubmitButton: UIBarButtonItem!
    
    
    var preferenceResponse = PreferenceResponse()
    var preferencesData: Preferences = Preferences()
    var preferenceItems: [PreferenceItem] = []
    
    //NEW
    private var completedStates: [Bool] = []
    
    //Dictionary of all the preferences
    private var selectedOptions: [String: [String]] = [
        "Niche": [],
        "Content Goals": [],
        "Content Tone": [],
        "Content Length": []
    ]
    
    let controller = PreferencesController()
    
    
    
    //    var firstItem: PreferenceGroup = PreferenceGroup()
    //    var secondItem: PreferenceGroup = PreferenceGroup()
    //    var thirdItem: ContentPreferenceGroup = ContentPreferenceGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
        
        preferencesData = preferenceResponse.preferences
        preferenceItems = preferencesData.toPreferenceItems()
        
        
        //NEW
        completedStates = Array(repeating: false, count: preferenceItems.count)
        
        //selectedOptions = Array(repeating: [], count: preferenceItems.count)
        
        
        registerCells()
        
        
        let layout = generateLayout()
        preferencesCollectionView.setCollectionViewLayout(layout, animated: true)
        
        preferencesCollectionView.dataSource = self
        //preferencesCollectionView.delegate = self
        preferencesCollectionView.clipsToBounds = false
        preferencesCollectionView.isPagingEnabled = false
        
        preferencesCollectionView.alwaysBounceVertical = false
        preferencesCollectionView.bounces = false
        
        //print(preferenceItems)
        
        
        //        print("preferencesCollectionView:", preferencesCollectionView as Any)
        //        print("delegate set to:", preferencesCollectionView.delegate as Any)
        //        print("isScrollEnabled:", preferencesCollectionView.isScrollEnabled)
        //        print("userInteractionEnabled:", preferencesCollectionView.isUserInteractionEnabled)
        
        
        
        //updateProgressAndPagination(forIndex: 0)
        pageControlOutlet.numberOfPages = preferenceItems.count
        pageControlOutlet.currentPage = 0
        
        
        UIView.performWithoutAnimation {
            updateSkipButton(for: 0)
            view.layoutIfNeeded()
        }
        
        updateProgressFromCompletedStates(animated: false)
        
    }
    
    
    
    @IBAction func submitButton(_ sender: Any) {
        _Concurrency.Task { @MainActor in
            do {
                // This updates the metadata flag to TRUE
                try await AuthManager.shared.completeOnboarding()
                
                let isYoutubeConnected = true
                
                try await controller.savePreferences(
                    dict: selectedOptions,
                    isYoutubeConnected: isYoutubeConnected
                )
                
                self.navigateToHomeScreen()
                
            } catch {
                print("Failed to update onboarding status: \(error)")
                // You might want to let them in anyway, or show an alert
                self.navigateToHomeScreen()
            }
        }
    }
    
    
    @IBAction func pageSelectorAction(_ sender: UIPageControl) {
        let page = sender.currentPage
        let indexPath = IndexPath(item: page, section: 0)
        preferencesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    
    //NEW
    func updateProgressFromCompletedStates(animated: Bool = true) {
        let completedCount = completedStates.filter { $0 }.count
        let total = preferenceItems.count
        guard total > 0 else { return }
        
        let progress = Float(completedCount) / Float(total)
        progessBarOutlet.setProgress(progress, animated: animated)
    }
    
    
    func updateProgressAndPagination(forIndex index: Int) {
        // Update Page Control
        pageControlOutlet.currentPage = index
        
        /*
         
         // Update Progress Bar
         // We add 1 because index starts at 0, but progress should be non-zero for the first item.
         // Example: Item 0 of 5 items = 1/5 (0.2) progress.
         let totalItems = Float(preferenceItems.count)
         
         // Prevent division by zero crash
         if totalItems > 0 {
         let currentStep = Float(index)
         let progress = currentStep / totalItems
         progessBarOutlet.setProgress(progress, animated: true)
         }
         
         */
        
        updateSkipButton(for: index)
    }
    
    
    func registerCells(){
        
        
        preferencesCollectionView.register(UINib(nibName: "NicheCollectionCardViewCell", bundle: nil), forCellWithReuseIdentifier: "nicheCard")
        
        preferencesCollectionView.register(UINib(nibName: "ContentGoalsCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "goalsCell")
        
        preferencesCollectionView.register(UINib(nibName: "ContentPreferencesCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "contentPreferencesCell")
        
        preferencesCollectionView.register(UINib(nibName: "ConnectAccountCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "connectAccountCell")
        
        preferencesCollectionView.register(UINib(nibName: "AccountConnectCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "accountCell")
    }
    
    
    
    //MARK: GENERATE LAYOUT FUNCTION
    
    func generateLayout() -> UICollectionViewLayout {
        
        
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        
        let item = NSCollectionLayoutItem(layoutSize: size)
        
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.95),
            heightDimension: .fractionalHeight(1.0)
        )
        
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        
        section.interGroupSpacing = 20
        
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        
        
        //PROGRESS BAR AND PAGE CONTROL LOGIC
        
        
        section.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) in
            guard let self = self else { return }
            
            // compute center X of the visible area
            let containerCenterX = offset.x + (env.container.contentSize.width / 2.0)
            
            // find the visible item whose center is nearest the container center
            let nearest = items.min { a, b in
                abs(a.frame.midX - containerCenterX) < abs(b.frame.midX - containerCenterX)
            }
            
            // fallback to 0 if nothing found
            let page = nearest?.indexPath.item ?? 0
            
            DispatchQueue.main.async {
                // update page control
                self.pageControlOutlet.numberOfPages = max(1, self.preferenceItems.count)
                self.pageControlOutlet.currentPage = page
                
                // update skip button without animations (prevents stutter)
                UIView.performWithoutAnimation {
                    self.updateSkipButton(for: page)
                    self.view.layoutIfNeeded()
                }
            }
        }
        // --- THE NEW LOGIC ENDS HERE ---
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
        
    }
    
    
    
    
}

extension PreferencesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return preferenceItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = preferenceItems[indexPath.item]
        
        //print(indexPath.item)
        
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nicheCard", for: indexPath) as! NicheCollectionCardViewCell
            cell.configureCell(with : item)
            
            //NEW
            cell.delegate = self
            cell.cardIndex = indexPath.item
            
            //updateSkipButton(for: indexPath.item)
            
            return cell
        }else if indexPath.item == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "goalsCell", for: indexPath) as! ContentGoalsCardCollectionViewCell
            cell.configureCell(with : item)
            
            //NEW
            cell.delegate = self
            cell.cardIndex = indexPath.item
            
            //updateSkipButton(for: indexPath.item)
            
            return cell
        }else if indexPath.item == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contentPreferencesCell", for: indexPath) as! ContentPreferencesCardCollectionViewCell
            cell.configureCell(with : item)
            
            //NEW
            cell.delegate = self
            cell.cardIndex = indexPath.item
            
            //updateSkipButton(for: indexPath.item)
            
            return cell
        }else if indexPath.item == 3{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "accountCell", for: indexPath) as! AccountConnectCollectionViewCell
            cell.configureCell(with : item)
            
            //NEW
            cell.delegate = self
            cell.cardIndex = indexPath.item
            
            //updateSkipButton(for: indexPath.item)
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nicheCard", for: indexPath) as! NicheCollectionCardViewCell
        cell.configureCell(with : item)
        cell.delegate = self
        cell.cardIndex = indexPath.item
        return cell
    }
    
    
    func updateSkipButton(for index: Int) {
        let lastIndex = preferenceItems.count - 1
        
        if index == lastIndex {
            skipSubmitButton.title = ""
            skipSubmitButton.image = UIImage(systemName: "checkmark")
        } else {
            skipSubmitButton.image = nil
            skipSubmitButton.title = "Skip"
        }
    }
}



//NEW
extension PreferencesViewController: PreferenceCardSelectionDelegate {
    func preferenceCard(at index: Int, didChangeCompletion isCompleted: Bool) {
        guard index >= 0 && index < completedStates.count else { return }
        
        // only update UI if state changed (avoids flicker)
        if completedStates[index] != isCompleted {
            completedStates[index] = isCompleted
            updateProgressFromCompletedStates()
        }
    }
    
    func preferenceCard(at key: String, didUpdateSelection selections: [String]) {
        selectedOptions[key] = selections.map { $0.lowercased() }
        //print(selectedOptions[key])
        print("\n\n\(selectedOptions)")
    }
    
    func openURL(_ url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
}









