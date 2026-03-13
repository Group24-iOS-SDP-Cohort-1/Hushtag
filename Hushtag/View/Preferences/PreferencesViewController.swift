import UIKit
import GoogleSignIn


protocol YouTubeConnectDelegate: AnyObject {
    func didTapConnectYouTube(from cell: AccountConnectCollectionViewCell)
}

protocol PreferenceCardSelectionDelegate: AnyObject {
    
    func preferenceCard(at index: Int, didChangeCompletion isCompleted: Bool)
    func preferenceCard(
        at key: String,
        didUpdateSelection selections: [String]
    )
}

class PreferencesViewController: UIViewController {
    
    @IBOutlet weak var preferencesCollectionView: UICollectionView!
    @IBOutlet weak var progessBarOutlet: UIProgressView!
    @IBOutlet weak var pageControlOutlet: UIPageControl!
    @IBOutlet weak var skipSubmitButton: UIBarButtonItem!
    
    var preferenceItems: [PreferenceItem] = PreferencesData.items
    private var completedStates: [Bool] = []
    private var selectedOptions: [String: [String]] = [
        "Niche": [],
        "Content Goals": [],
        "Content Tone": [],
        "Content Length": []
    ]
    
    let controller = PreferencesController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        completedStates = Array(repeating: false, count: preferenceItems.count)
        registerCells()
        
        let layout = generateLayout()
        preferencesCollectionView.setCollectionViewLayout(layout, animated: true)
        
        preferencesCollectionView.dataSource = self
        preferencesCollectionView.clipsToBounds = false
        preferencesCollectionView.isPagingEnabled = false
        
        preferencesCollectionView.alwaysBounceVertical = false
        preferencesCollectionView.bounces = false
        
        pageControlOutlet.numberOfPages = preferenceItems.count
        pageControlOutlet.currentPage = 0
        
        UIView.performWithoutAnimation {
            updateSkipButton(for: 0)
            view.layoutIfNeeded()
        }
        
        updateProgressFromCompletedStates(animated: false)
        
        checkExistingYouTubeConnection()
        
    }
    
    private func checkExistingYouTubeConnection() {
        Task {
            let isConnected = await YouTubeController.shared.checkYouTubeConnection()
            if isConnected {
                
                
                do {
                    //print("⏳ Google Login Complete: Testing proxy fetch for analytics...")
                    
                    let analyticsData = try await YouTubeController.shared.fetchAnalytics(
                        startDate: "2026-01-01",
                        endDate: "2026-02-26"
                    )
                    
                    if let _ = String(data: analyticsData, encoding: .utf8) {
                        //print("📈 GOOGLE SUCCESS - Raw YouTube Data:")
                        //print(jsonString)
                    }
                } catch {
                    //print("❌ GOOGLE PROXY FETCH FAILED: \(error)")
                }
                
                await MainActor.run {
                    
                    if self.completedStates.count > 3 {
                        self.completedStates[3] = true
                        self.updateProgressFromCompletedStates()
                        
                        
                        self.preferencesCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    
    
    @IBAction func submitButton(_ sender: Any) {
        _Concurrency.Task { @MainActor in
            do {
                
                try await AuthManager.shared.completeOnboarding()
                
                let isYoutubeConnected = completedStates.last == true
                
                
                try await controller.savePreferences(
                    dict: selectedOptions,
                    isYoutubeConnected: isYoutubeConnected
                )
                
                self.navigateToHomeScreen()
                
            } catch {
                //print("Failed to update onboarding status: \(error)")
                
                self.navigateToHomeScreen()
            }
        }
    }
    
    
    @IBAction func pageSelectorAction(_ sender: UIPageControl) {
        let page = sender.currentPage
        let indexPath = IndexPath(item: page, section: 0)
        preferencesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    
    
    func updateProgressFromCompletedStates(animated: Bool = true) {
        let completedCount = completedStates.filter { $0 }.count
        let total = preferenceItems.count
        guard total > 0 else { return }
        
        let progress = Float(completedCount) / Float(total)
        progessBarOutlet.setProgress(progress, animated: animated)
    }
    
    
    func updateProgressAndPagination(forIndex index: Int) {
        
        pageControlOutlet.currentPage = index
        
        
        updateSkipButton(for: index)
    }
    
    
    func registerCells(){
        
        
        preferencesCollectionView.register(UINib(nibName: "NicheCollectionCardViewCell", bundle: nil), forCellWithReuseIdentifier: "nicheCard")
        
        preferencesCollectionView.register(UINib(nibName: "ContentGoalsCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "goalsCell")
        
        preferencesCollectionView.register(UINib(nibName: "ContentPreferencesCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "contentPreferencesCell")
        
        preferencesCollectionView.register(UINib(nibName: "ConnectAccountCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "connectAccountCell")
        
        preferencesCollectionView.register(UINib(nibName: "AccountConnectCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "accountCell")
    }
    
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
        
        section.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) in
            guard let self = self else { return }
            
            
            let containerCenterX = offset.x + (env.container.contentSize.width / 2.0)
            
            
            let nearest = items.min { a, b in
                abs(a.frame.midX - containerCenterX) < abs(b.frame.midX - containerCenterX)
            }
            
            
            let page = nearest?.indexPath.item ?? 0
            
            DispatchQueue.main.async {
                
                self.pageControlOutlet.numberOfPages = max(1, self.preferenceItems.count)
                self.pageControlOutlet.currentPage = page
                
                
                UIView.performWithoutAnimation {
                    self.updateSkipButton(for: page)
                    self.view.layoutIfNeeded()
                }
            }
        }
        
        
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
        
        
        
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nicheCard", for: indexPath) as! NicheCollectionCardViewCell
            cell.configureCell(with : item)
            
            
            cell.delegate = self
            cell.cardIndex = indexPath.item
            
            
            
            return cell
        }else if indexPath.item == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "goalsCell", for: indexPath) as! ContentGoalsCardCollectionViewCell
            cell.configureCell(with : item)
            
            
            cell.delegate = self
            cell.cardIndex = indexPath.item
            
            
            
            return cell
        }else if indexPath.item == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contentPreferencesCell", for: indexPath) as! ContentPreferencesCardCollectionViewCell
            cell.configureCell(with : item)
            
            
            cell.delegate = self
            cell.cardIndex = indexPath.item
            
            
            
            return cell
        } else if indexPath.item == 3{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "accountCell", for: indexPath) as! AccountConnectCollectionViewCell
            
            
            cell.isConnected = completedStates[indexPath.item]
            
            cell.configureCell(with : item)
            
            
            cell.delegate = self
            cell.delegate1 = self
            cell.cardIndex = indexPath.item
            
            
            
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

extension PreferencesViewController: PreferenceCardSelectionDelegate {
    func preferenceCard(at index: Int, didChangeCompletion isCompleted: Bool) {
        guard index >= 0 && index < completedStates.count else { return }
        
        
        if completedStates[index] != isCompleted {
            completedStates[index] = isCompleted
            updateProgressFromCompletedStates()
        }
    }
    
    func preferenceCard(at key: String, didUpdateSelection selections: [String]) {
        selectedOptions[key] = selections.map { $0.lowercased() }
        //print(selectedOptions[key])
        //print("\n\n\(selectedOptions)")
    }
    
}

extension PreferencesViewController: YouTubeConnectDelegate {
    func didTapConnectYouTube(from cell: AccountConnectCollectionViewCell) {
        connectYouTube(cell: cell)
    }
    
    func connectYouTube(cell: AccountConnectCollectionViewCell) {
        
        let viewModel = SignInModel()
        
        Task {
            do {
                try await viewModel.connectYouTube()
                
                do {
                    //print("⏳ Testing proxy fetch for analytics...")
                    
                    let analyticsData = try await YouTubeController.shared.fetchAnalytics(
                        startDate: "2026-01-01",
                        endDate: "2026-02-26"
                    )
                    
                    
                    if let _ = String(data: analyticsData, encoding: .utf8) {
                        //print("📈 PROXY SUCCESS - Raw YouTube Data:")
                        //print(jsonString)
                    }
                } catch {
                    //print("❌ PROXY FETCH FAILED: \(error)")
                }
                
                await MainActor.run {
                    cell.isConnected = true
                    cell.updateButtonAppearance(
                        cell.youtubeOutlet,
                        isSelected: true
                    )
                    
                    self.completedStates[cell.cardIndex] = true
                    self.updateProgressFromCompletedStates()
                    
                    let alert = UIAlertController(title: "Success", message: "Successfully connected YouTube account!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
                
            } catch {
                await MainActor.run {
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
                //print("❌ YouTube connect failed:", error)
            }
        }
    }
}
