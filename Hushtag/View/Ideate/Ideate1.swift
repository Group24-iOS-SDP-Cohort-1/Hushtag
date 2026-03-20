import UIKit

class Ideate1: UIViewController {
    
    var ideas: [Idea] = []
    var selectedIdea: Idea?
    var selectedIndexPath: IndexPath?
    private let likedIdeasController = LikedIdeasController()
    var isSearching: Bool = false
    
    // NEW: Recent Scripts Data
    var recentScripts: [ScriptedIdea] = []
    private let scriptsController = ScriptedIdeasController()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scriptButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        register()
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLikeUpdate(_:)),
            name: .didUpdateLikedStatus,
            object: nil
        )
        
        scriptButton.layer.borderWidth = 1
        scriptButton.layer.borderColor = UIColor.accent.cgColor
        
        setupGlobalKeyboardDismiss()
        
        self.ideas = syncLikedState(SessionManager.shared.personalizedIdeas)
        // Fetch recent scripts
        fetchRecentScripts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRecentScripts()
    }
    
    private func fetchRecentScripts() {
        Task {
            do {
                // Fetch conversations to get sorted scripted ideas
                let conversations = try await scriptsController.fetchConversations()
                
                // Extract scripts from conversations that have them
                let allScripts = conversations.compactMap { conversation -> ScriptedIdea? in
                    guard let dbScript = conversation.scripted_ideas else { return nil }
                    return ScriptedIdea(
                        id: dbScript.id,
                        chat_id: dbScript.chat_id,
                        title: dbScript.title,
                        description: dbScript.description,
                        script: dbScript.script,
                        thumbnail: dbScript.thumbnail,
                        tags: dbScript.tags
                    )
                }
                
                // Take top 4 (already sorted by created_at in fetchConversations)
                let top4 = Array(allScripts.prefix(4))
                
                await MainActor.run {
                    self.recentScripts = top4
                    self.collectionView.reloadData()
                }
            } catch {
                print("Error fetching recent scripts: \(error)")
            }
        }
    }
    
    private func register() {
        collectionView.register(UINib(nibName: "IdeaCells", bundle: nil), forCellWithReuseIdentifier: "ideaCell")
        
        // NEW: Register Script Cell and Header
        collectionView.register(UINib(nibName: "Script_cell_ideate", bundle: nil), forCellWithReuseIdentifier: "scriptCellIdeate")
        // Use existing HeaderView
        collectionView.register(UINib(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerCell")
        
        collectionView.register(UINib(nibName: "IdeaSearch", bundle:nil ),forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "IdeaSearch")
    }
    
    private func setupGlobalKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    @objc private func handleLikeUpdate(_ notification: Notification) {
        guard let ideaKey = notification.object as? String,
              let index = ideas.firstIndex(where: { $0.ideaKey == ideaKey }) else {
            return
        }
        
        ideas[index].liked = LikedIds.likedIdeaIds.contains(ideaKey)
        
        // Dynamic section adjustment
        let suggestedSectionIndex = (recentScripts.isEmpty || isSearching) ? 1 : 2
        
        if let cell = collectionView.cellForItem(
            at: IndexPath(row: index, section: suggestedSectionIndex)
        ) as? IdeaCells {
            cell.configure(idea: ideas[index])
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func scriptTap(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Chatbot")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    @IBAction func viewLikedTap(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "ViewScripts", bundle: nil)
        guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController else {return}
        guard let destinationVC = navVC.topViewController as? ViewScriptsViewController else {return}
        destinationVC.pageTitle = "Liked Ideas"
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            
            // Section 0: Search Header
            if sectionIndex == 0 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(1))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
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
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0)
                
                return section
            }
            
            // Determine if Section 1 is "Recent Scripts" or "Suggested"
            let isRecentScriptsSection = !self.recentScripts.isEmpty && !self.isSearching && sectionIndex == 1
            
            if isRecentScriptsSection {
                // Horizontal Layout for Recent Scripts
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.95),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                //item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.47),
                    heightDimension: .estimated(120)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0)
                
                // Header (using HeaderView)
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(self.isSearching ? 0 : 50)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                section.boundarySupplementaryItems = [header]
                
                return section
            }
            
            // Section 2 (or 1): Suggested Ideas (Vertical List)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(116)
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
                heightDimension: .estimated(50)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            header.contentInsets = NSDirectionalEdgeInsets(top: -5, leading: 0, bottom: 0, trailing: 0)
            
            section.boundarySupplementaryItems = [header]
            section.interGroupSpacing = 15
            let sectionTopInset: CGFloat = self.isSearching ? 0 : 5
            section.contentInsets = NSDirectionalEdgeInsets(top: sectionTopInset, leading: 0, bottom: 0, trailing: 0)
            
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
    
    private func syncLikedState(_ ideas: [Idea]) -> [Idea] {
        let likedKeys = LikedIds.likedIdeaIds
        
        return ideas.map { idea in
            var updated = idea
            
            guard let key = idea.ideaKey else {
                updated.liked = false
                return updated
            }
            
            updated.liked = likedKeys.contains(key)
            return updated
        }
    }
    
    
    
    func loadIdeasFromPreferences() async {
        
        guard let prefs = SessionManager.shared.userPreferences else {
            print("❌ No preferences found")
            return
        }
        
        let topics = prefs.niche
        
        guard topics.count >= 3 else {
            print("❌ Not enough niche topics")
            return
        }
        
        let selectedTopics = Array(topics.prefix(5))
        
        print("🎯 Fetching ideas for:", selectedTopics)
        
        var personalizedIdeas: [Idea] = []
        
        for topic in selectedTopics {
            
            do {
                let response = try await YouTubeService().search(query: topic.rawValue)
                
                if let firstIdea = response.clusterIdeas
                    .flatMap({ $0.ideas })
                    .first {
                    let key = makeIdeaKey(
                        title: firstIdea.title,
                        description: firstIdea.description,
                        format: firstIdea.format,
                        hashtags: firstIdea.hashtags
                    )
                    
                    let mapped = Idea(
                        id: UUID(),
                        ideaKey: key,
                        title: firstIdea.title,
                        description: firstIdea.description,
                        format: firstIdea.format,
                        hashtags: firstIdea.hashtags,
                        noveltyScore: firstIdea.noveltyScore,
                        videos: response.clusterIdeas.first?.videos.map { $0.toVideo() },
                        liked: false
                    )
                    
                    
                    personalizedIdeas.append(mapped)
                }
                
            } catch {
                print("❌ Error fetching topic \(topic):", error)
            }
        }
        
        // Update UI
        await MainActor.run {
            self.ideas = personalizedIdeas
            self.collectionView.reloadData()
            print("✅ Loaded \(ideas.count) personalized ideas")
        }
    }
}

extension Ideate1: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (recentScripts.isEmpty || isSearching) ? 2 : 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        
        if !recentScripts.isEmpty && !isSearching && section == 1 {
            return recentScripts.count
        }
        
        return ideas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Recent Scripts Section
        if !recentScripts.isEmpty && !isSearching && indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "scriptCellIdeate", for: indexPath) as! Script_cell_ideate
            let script = recentScripts[indexPath.row]
            cell.configureCell(with: script)
            return cell
        }
        
        // Suggested Ideas Section (Fallback for other sections)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ideaCell",for: indexPath) as! IdeaCells
        
        let idea = ideas[indexPath.row]
        cell.configure(idea: idea)
        cell.delegate = self
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
            
        } else if !recentScripts.isEmpty && !isSearching && indexPath.section == 1 {
            // Recent Scripts Header using HeaderView
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "headerCell",
                for: indexPath
            ) as! HeaderView
            header.configureHeader(text: "Recent Script")
            header.showChevron(true)
            
            header.didTapChevron = { [weak self] in
                let storyboard = UIStoryboard(name: "ViewScripts", bundle: nil)
                guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController else {return}
                guard let destinationVC = navVC.topViewController as? ViewScriptsViewController else {return}
                destinationVC.pageTitle = "Your Scripts"
                self?.navigationController?.pushViewController(destinationVC, animated: true)
            }
            
            return header
            
        } else {
            // Suggested Header
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "headerCell",
                for: indexPath
            ) as! HeaderView
            header.configureHeader(text: "Suggested For You")
            header.showChevron(false) // No chevron for suggested
            header.isHidden = isSearching
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Handle Tap on Recent Script
        if !recentScripts.isEmpty && !isSearching && indexPath.section == 1 {
            let script = recentScripts[indexPath.row]
            let storyboard = UIStoryboard(name: "Ideate", bundle: nil)
            if let destinationVC = storyboard.instantiateViewController(withIdentifier: "scriptedIdea") as? ScriptedIdeas {
                destinationVC.idea = script
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
            return
        }
        
        // Handle Tap on Suggested Idea (correct section index)
        let suggestedSectionIndex = (recentScripts.isEmpty || isSearching) ? 1 : 2
        
        if indexPath.section == suggestedSectionIndex {
            let idea = ideas[indexPath.row]
            let storyboard = UIStoryboard(name: "ViewIdea", bundle: nil)
            guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController else {return}
            guard let destinationVC = navVC.topViewController as? ViewIdea else {return}
            destinationVC.idea = idea
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
}

extension Notification.Name {
    static let didUpdateLikedStatus = Notification.Name("didUpdateLikedStatus")
}

extension Ideate1: IdeaSearchDelegate {
    
    func didTapSearch(with keyword: String) {
        
        if keyword.isEmpty {
            self.isSearching = false
            self.ideas = syncLikedState(SessionManager.shared.personalizedIdeas)
            collectionView.reloadData()
            return
        }
        
        self.isSearching = true
        
        OpaqueLoadingScreen.shared.show(message: "Searching ideas...")

        
        Task {
            do {
                let response = try await YouTubeService().search(query: keyword)
                
                // NEW FLOW
                let clusterIdeas = response.clusterIdeas
                collectionView.setCollectionViewLayout(generateLayout(), animated: false)
                
                // Flatten clusterIdeas → Idea objects
                let mappedIdeas: [Idea] = clusterIdeas.flatMap { cluster in
                    cluster.ideas.map { geminiIdea in
                        
                        let key = makeIdeaKey(
                            title: geminiIdea.title,
                            description: geminiIdea.description,
                            format: geminiIdea.format,
                            hashtags: geminiIdea.hashtags
                        )
                        
                        return Idea(
                            id: UUID(),
                            ideaKey: key,
                            title: geminiIdea.title,
                            description: geminiIdea.description,
                            format: geminiIdea.format,
                            hashtags: geminiIdea.hashtags,
                            noveltyScore: geminiIdea.noveltyScore,
                            videos: (cluster.videos).map { $0.toVideo() },
                            liked: false
                        )
                    }
                }
                
                
                await MainActor.run {
                    self.ideas = mappedIdeas
                    print("Ideas Count:", self.ideas.count)
                    self.collectionView.reloadData()
                    OpaqueLoadingScreen.shared.hide()
                }
                
            } catch {
                print("❌ ERROR:", error)
                await MainActor.run {
                    OpaqueLoadingScreen.shared.hide()
                }
            }
        }
    }
}

extension Ideate1: IdeaCellDelegate {
    
    func didToggleLikeFromFeed(for ideaKey: String) {
        
        guard let index = ideas.firstIndex(where: { $0.ideaKey == ideaKey }) else {
            return
        }
        
        let isCurrentlyLiked = LikedIds.likedIdeaIds.contains(ideaKey)
        let idea = ideas[index]
        
        Task {
            do {
                if isCurrentlyLiked {
                    //  UNLIKE
                    try await likedIdeasController.unlikeIdea(ideaKey: ideaKey)
                    LikedIds.likedIdeaIds.remove(ideaKey)
                } else {
                    //  LIKE
                    try await likedIdeasController.likeIdea(idea)
                    LikedIds.likedIdeaIds.insert(ideaKey)
                }
                
                await MainActor.run {
                    // Update Ideate list
                    ideas[index].liked = !isCurrentlyLiked
                    
                    // Keep SessionManager in sync (VERY important)
                    if let smIndex = SessionManager.shared.personalizedIdeas
                        .firstIndex(where: { $0.ideaKey == ideaKey }) {
                        SessionManager.shared.personalizedIdeas[smIndex].liked = !isCurrentlyLiked
                    }
                    
                    // Notify other screens
                    NotificationCenter.default.post(
                        name: .didUpdateLikedStatus,
                        object: ideaKey
                    )
                    
                    let suggestedSectionIndex = (recentScripts.isEmpty || self.isSearching) ? 1 : 2
                    if let cell = collectionView.cellForItem(
                        at: IndexPath(row: index, section: suggestedSectionIndex)
                    ) as? IdeaCells {
                        cell.updateLikeUI()
                    }
                }
                
            } catch {
                print("❌ Like toggle failed:", error)
            }
        }
    }
}
