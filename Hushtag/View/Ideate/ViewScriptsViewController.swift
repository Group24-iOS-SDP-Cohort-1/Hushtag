import UIKit

class ViewScriptsViewController: UIViewController {
    //var ideaResponse = IdeaResponse()
    var ideas: [Idea] = []
    private let likedIdeasController = LikedIdeasController()
    
    var pageTitle: String = ""
    var cellReuseIdentifier: String = "allScriptsCell"
    
    var isSearchMode = false
    var likedIdeas: [Idea] = []
    var myScripts: [ScriptedIdea] = []
    var chatHistory: [ChatMessageDB] = []
    
    
    let controller = ScriptedIdeasController()
    
    // Search related properties
    private let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var filteredMyScripts: [ScriptedIdea] = []
    var filteredLikedIdeas: [Idea] = []
    
    @IBOutlet weak var scriptsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
        setupTapToDismiss()
        navigationItem.title = pageTitle
        scriptsCollectionView.dataSource = self
        scriptsCollectionView.delegate = self
        
        scriptsCollectionView.register(UINib(nibName: "ScriptsCell1", bundle: nil), forCellWithReuseIdentifier: "scriptedIdeas")
        scriptsCollectionView.register(UINib(nibName: "LikedCellsNew", bundle: nil), forCellWithReuseIdentifier: "likedCellsNew")
        
        
        let layout = generateScriptsLayout(title: pageTitle)
        scriptsCollectionView.setCollectionViewLayout(layout, animated: true)
        
        if pageTitle == "Chat History" || pageTitle == "Your Scripts" {
            fetchMyScripts()
        } else {
            syncLikedIdeas()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh the list every time the view appears
        if pageTitle == "Your Scripts" || pageTitle == "Chat History" {
            fetchMyScripts()
        }
    }
    
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        //searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "Search by title or tags"
        //searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    
    func setupTapToDismiss() {
        // Add gesture to the collection view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        // IMPORTANT: This allows taps to pass through to the cells if you tap a cell.
        // If you tap empty space, this gesture fires.
        // If you tap a cell, the didSelectItemAt delegate fires as well.
        tapGesture.cancelsTouchesInView = false
        
        scriptsCollectionView.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        // This closes the keyboard safely
        view.endEditing(true)
        
        // Optional: If you want to deactivate the search bar completely (like clicking Cancel)
        // searchController.isActive = false
    }
    
    
    func fetchMyScripts() {
        Task {
            do {
                // Fetch conversations to get sorted scripted ideas
                let conversations = try await controller.fetchConversations()
                
                // Extract scripts from conversations that have them
                let scripts = conversations.compactMap { conversation -> ScriptedIdea? in
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

                await MainActor.run {
                    self.myScripts = scripts
                    self.filteredMyScripts = scripts
                    
                    if self.isFiltering {
                        self.filterContentForSearchText(self.searchController.searchBar.text ?? "")
                    } else {
                        self.scriptsCollectionView.reloadData()
                        self.updateEmptyState()
                    }
                }
            } catch {
                print("Error fetching scripts: \(error)")
            }
        }
    }
    
    
    //    @objc func syncLikedIdeas() {
    //        likedIdeas = ideas.filter { LikedIds.likedIdeaIds.contains($0.id) }
    //        scriptsCollectionView.reloadData()
    //        updateEmptyState()
    //    }
    
    @objc func syncLikedIdeas() {
        Task {
            do {
                let ideas = try await likedIdeasController.fetchLikedIdeas()
                
                await MainActor.run {
                    self.likedIdeas = ideas
                    self.filteredLikedIdeas = ideas
                    self.scriptsCollectionView.reloadData()
                    self.updateEmptyState()
                }
            } catch {
                print("Failed to fetch liked ideas:", error)
            }
        }
    }
    
    
    private func updateEmptyState() {
        
        // Separate Empty State logic for "Your Scripts"
        if pageTitle == "Chat History" || pageTitle == "Your Scripts" {
            if myScripts.isEmpty {
                showEmptyView(message: "No scripts yet", iconName: "doc.text")
                scriptsCollectionView.backgroundView?.isHidden = false
            } else {
                scriptsCollectionView.backgroundView = nil
            }
            return
        }
        
        // Logic for "Liked Ideas"
        if likedIdeas.isEmpty {
            showEmptyView(message: "No liked ideas", iconName: "heart.slash")
            scriptsCollectionView.backgroundView?.isHidden = false
        } else {
            scriptsCollectionView.backgroundView = nil
        }
    }
    
    // Helper to draw empty view
    private func showEmptyView(message: String, iconName: String) {
        let emptyView = UIView(frame: scriptsCollectionView.bounds)
        
        let imageView = UIImageView(image: UIImage(systemName: iconName))
        imageView.tintColor = .tertiaryLabel
        imageView.heightAnchor.constraint(equalToConstant: 38).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 38).isActive = true
        
        let label = UILabel()
        label.text = message
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        
        emptyView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor)
        ])
        
        scriptsCollectionView.backgroundView = emptyView
    }
    
}

extension ViewScriptsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if pageTitle == "Chat History" || pageTitle == "Your Scripts" {
            // If searching, use filtered list. Else, use full list.
            return isFiltering ? filteredMyScripts.count : myScripts.count
        } else {
            return isFiltering ? filteredLikedIdeas.count : likedIdeas.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if pageTitle == "Chat History" || pageTitle == "Your Scripts" {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "scriptedIdeas",
                for: indexPath
            ) as! ScriptsCell1
            
            // Fetch correct object based on search state
            let script: ScriptedIdea
            if isFiltering {
                script = filteredMyScripts[indexPath.row]
            } else {
                script = myScripts[indexPath.row]
            }
            
            cell.configureCell(with: script)
            return cell
        }
        
        // Logic for Liked Ideas
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "likedCellsNew",
            for: indexPath
        ) as! LikedCellsNew
        
        let idea: Idea
        if isFiltering {
            idea = filteredLikedIdeas[indexPath.row]
        } else {
            idea = likedIdeas[indexPath.row]
        }
        
        cell.configureCell(idea: idea)
        cell.delegate = self

        return cell
    }
}

func generateScriptsLayout(title: String) -> UICollectionViewLayout{
    if title == "Chat History" || title == "Your Scripts" {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(147)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 15
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10, leading: 10, bottom: 10, trailing: 10
        )
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        print("Chat History")
        
        return layout
    }
    
    let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(120)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
    
    let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(170)
    )
    let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: groupSize,
        subitems: [item]
    )
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 15
    section.contentInsets = NSDirectionalEdgeInsets(
        top: 10, leading: 10, bottom: 10, trailing: 10
    )
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    return layout
    
}

extension ViewScriptsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if pageTitle == "Chat History" || pageTitle == "Your Scripts" {
            
            // Get the correct script based on search state
            let script: ScriptedIdea
            if isFiltering {
                script = filteredMyScripts[indexPath.row]
            } else {
                script = myScripts[indexPath.row]
            }
            
            let storyboard = UIStoryboard(name: "Ideate", bundle: nil)
            if let destinationVC = storyboard.instantiateViewController(withIdentifier: "scriptedIdea") as? ScriptedIdeas {
                destinationVC.idea = script
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
            return
        }
    }
    
}

extension ViewScriptsViewController: LikedCellDelegate {
    
    func didToggleLike(for ideaKey: String) {
        
        let sourceArray = isFiltering ? filteredLikedIdeas : likedIdeas
        
        guard let index = sourceArray.firstIndex(where: { $0.ideaKey == ideaKey }) else {
            return
        }
        
        let idea = sourceArray[index]
        let isCurrentlyLiked = LikedIds.likedIdeaIds.contains(ideaKey)
        
        Task {
            do {
                if isCurrentlyLiked {
                    //  UNLIKE
                    try await likedIdeasController.unlikeIdea(ideaKey: ideaKey)
                    LikedIds.likedIdeaIds.remove(ideaKey)
                    
                    //  UPDATE SESSION MANAGER (THIS FIXES IDEATE)
                    if let smIndex = SessionManager.shared.personalizedIdeas
                        .firstIndex(where: { $0.ideaKey == ideaKey }) {
                        SessionManager.shared.personalizedIdeas[smIndex].liked = false
                    }
                    
                } else {
                    //  LIKE
                    try await likedIdeasController.likeIdea(idea)
                    LikedIds.likedIdeaIds.insert(ideaKey)
                    
                    if let smIndex = SessionManager.shared.personalizedIdeas
                        .firstIndex(where: { $0.ideaKey == ideaKey }) {
                        SessionManager.shared.personalizedIdeas[smIndex].liked = true
                    }
                }
                
                await MainActor.run {
                    
                    // Remove from local lists if unliked
                    if isCurrentlyLiked {
                        self.likedIdeas.removeAll { $0.ideaKey == ideaKey }
                        self.filteredLikedIdeas.removeAll { $0.ideaKey == ideaKey }
                    }
                    
                    NotificationCenter.default.post(
                        name: .didUpdateLikedStatus,
                        object: ideaKey
                    )
                    
                    self.scriptsCollectionView.reloadData()
                }
                
            } catch {
                print("❌ Like toggle failed:", error)
            }
        }
    }
    
    func didTapDraftScript(for idea: Idea) {
        
        Task {
            do {
                guard let ideaKey = idea.ideaKey else { return }
                
                var convoId = try await likedIdeasController.fetchConvoId(for: ideaKey)
                var isNew = false
                
                if convoId == nil {
                    let newConvoId = UUID()
                    
                    _ = try await ScriptedIdeasController().addConversation(id: newConvoId)
                    
                    try await likedIdeasController.attachConvoId(
                        to: ideaKey,
                        convoId: newConvoId
                    )
                    
                    convoId = newConvoId
                    isNew = true
                }
                
                guard let finalConvoId = convoId else { return }
                
                await MainActor.run {
                    
                    let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)
                    
                    guard let vc = storyboard.instantiateViewController(
                        withIdentifier: "Chatbot"
                    ) as? Chatbot else { return }
                    
                    vc.conversationID = finalConvoId
                    
                    if isNew {
                        vc.autoSendMessage = """
                        Generate a short engaging social media video script.
                        
                        Idea Title: \(idea.title)
                        
                        Idea Description: \(idea.description)
                        
                        The script should include:
                        - Hook
                        - Main content
                        - Ending CTA
                        """
                    }
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            } catch {
                print("❌ Failed to handle convo_id:", error)
            }
        }
    }
}


extension ViewScriptsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        // 1. Filter "Your Scripts"
        filteredMyScripts = myScripts.filter { (script: ScriptedIdea) -> Bool in
            
            if searchText.isEmpty { return true }
            
            // Check Title (User defined)
            let titleMatch = script.title?.lowercased().contains(searchText.lowercased()) ?? false
            
            let tagsMatch = script.tags?.contains { tag in
                tag.lowercased().contains(searchText.lowercased())
            } ?? false
            
            return titleMatch || tagsMatch
        }
        
        // 2. Filter "Liked Ideas" (Optional, if you want search on this page too)
        filteredLikedIdeas = likedIdeas.filter { (idea: Idea) -> Bool in
            if searchText.isEmpty { return true }
            return idea.title.lowercased().contains(searchText.lowercased())
        }
        
        scriptsCollectionView.reloadData()
        
        // Update empty state based on search results if searching
        if isFiltering {
            if (pageTitle == "Chat History" || pageTitle == "Your Scripts") && filteredMyScripts.isEmpty {
                showEmptyView(message: "No results found", iconName: "magnifyingglass")
                scriptsCollectionView.backgroundView?.isHidden = false
            } else if pageTitle != "Chat History" && filteredLikedIdeas.isEmpty {
                showEmptyView(message: "No results found", iconName: "magnifyingglass")
                scriptsCollectionView.backgroundView?.isHidden = false
            } else {
                scriptsCollectionView.backgroundView = nil
            }
        } else {
            updateEmptyState()
        }
    }
    
    // Helper to determine if we are currently filtering
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
}
