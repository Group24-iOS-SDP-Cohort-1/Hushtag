//
//  ViewScriptsViewController.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

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
    
    private let scriptsController = ScriptedIdeasController()
    
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
        
        //scriptsCollectionView.keyboardDismissMode = .onDrag
        setupTapToDismiss()         //CHECK IF WE REALLY NEED TAP TO DISMIS, because collection view is taking the full screen space
        
        //        ideas = ideaResponse.ideas
        //        likedIdeas = ideas.filter { LikedIds.likedIdeaIds.contains($0.id) }
        navigationItem.title = pageTitle
        scriptsCollectionView.dataSource = self
        scriptsCollectionView.delegate = self
        
        scriptsCollectionView.register(UINib(nibName: "ScriptsCell1", bundle: nil), forCellWithReuseIdentifier: "scriptedIdeas")
        scriptsCollectionView.register(UINib(nibName: "LikedCellsNew", bundle: nil), forCellWithReuseIdentifier: "likedCellsNew")
        
        
        let layout = generateScriptsLayout(title: pageTitle)
        scriptsCollectionView.setCollectionViewLayout(layout, animated: true)
        
        if pageTitle == "Your Scripts" {
            // 1. Fetch from Supabase
            fetchMyScripts()
        } else {
            // 2. Load Liked Ideas (Existing Logic)
            //ideas = ideaResponse.ideas
//            likedIdeas = ideas.filter { LikedIds.likedIdeaIds.contains($0.id) }
//            NotificationCenter.default.addObserver(self, selector: #selector(syncLikedIdeas), name: .didUpdateLikedStatus, object: nil)
//            updateEmptyState()
            syncLikedIdeas()
      }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh the list every time the view appears
        if pageTitle == "Your Scripts" {
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
                // 1. Fetch fresh data from Supabase (Item is gone here)
                let scripts = try await scriptsController.fetchScripts()
                
                await MainActor.run {
                    // 2. Update the main source of truth
                    self.myScripts = scripts
                    
                    // 3. FIX: If we are searching, re-filter the new list immediately.
                    // This removes the "ghost" item from the search results.
                    if self.isFiltering {
                        self.filterContentForSearchText(self.searchController.searchBar.text ?? "")
                    } else {
                        // Otherwise, just reload normally
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
        if pageTitle == "Your Scripts" {
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
        if pageTitle == "Your Scripts" {
            // If searching, use filtered list. Else, use full list.
            return isFiltering ? filteredMyScripts.count : myScripts.count
        } else {
            return isFiltering ? filteredLikedIdeas.count : likedIdeas.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if pageTitle == "Your Scripts" {
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
        
        // ... (Keep your existing Like Toggle logic here) ...
        // Note: Be careful deleting items while searching.
        // Ideally, delete from both 'likedIdeas' AND 'filteredLikedIdeas'
        
        return cell
    }
}

func generateScriptsLayout(title: String) -> UICollectionViewLayout{
    if title == "Your Scripts"{
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
        
        print("Your Scripts")
        
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
    
    print("Liked ideas")
    
    return layout
    
}

extension ViewScriptsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if pageTitle == "Your Scripts" {
            
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

    func didToggleLike(for ideaKey: String)
        {

            // Decide which array we are working on
            let sourceArray = isFiltering ? filteredLikedIdeas : likedIdeas

            guard let index = sourceArray.firstIndex(where: { $0.ideaKey == ideaKey })
                else {
                print("❌ Idea not found for toggle")
                return
            }

            Task {
                do {
                    let idea = sourceArray[index]

                    if idea.liked == true {
                        // UNLIKE
                        try await likedIdeasController.unlikeIdea(ideaKey: ideaKey)


                        await MainActor.run {
                            if self.isFiltering {
                                self.filteredLikedIdeas[index].liked = false
                                if let mainIndex = self.likedIdeas.firstIndex(where: { $0.ideaKey == ideaKey }) {
                                    self.likedIdeas[mainIndex].liked = false
                                }

                            } else {
                                self.likedIdeas[index].liked = false
                            }
                            NotificationCenter.default.post(
                                name: .didUpdateLikedStatus,
                                object: ideaKey
                            )

                        }

                    } else {
                        // LIKE
                        try await likedIdeasController.likeIdea(idea)

                        await MainActor.run {
                            if self.isFiltering {
                                self.filteredLikedIdeas[index].liked = true
                                if let mainIndex = self.likedIdeas.firstIndex(where: { $0.ideaKey == ideaKey }) {
                                    self.likedIdeas[mainIndex].liked = false
                                }

                            } else {
                                self.likedIdeas[index].liked = true
                            }
                        }
                    }

                    await MainActor.run {
                        self.syncLikedIdeas()
                    }


                } catch {
                    print("❌ Like toggle failed:", error)
                }
            }
        }


    
    func didTapDraftScript(for idea: Idea) {
        let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)
        guard let chatVC = storyboard.instantiateViewController(
            withIdentifier: "Chatbot"
        ) as? Chatbot else { return }
        chatVC.autoSendMessage = "script"
        navigationController?.pushViewController(chatVC, animated: true)
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
            
            // Check Mock Title (AI Generated)
            let mockTitleMatch = script.mockTitle?.lowercased().contains(searchText.lowercased()) ?? false
            
            // Check Tags (Array of strings)
            // Note: Ensure your ScriptedIdea model has a 'tags' property.
            // If it doesn't, remove this line or map it to a relevant property.
            let tagsMatch = script.tags?.contains { tag in
                tag.lowercased().contains(searchText.lowercased())
            } ?? false
            
            return titleMatch || mockTitleMatch || tagsMatch
        }
        
        // 2. Filter "Liked Ideas" (Optional, if you want search on this page too)
        filteredLikedIdeas = likedIdeas.filter { (idea: Idea) -> Bool in
            if searchText.isEmpty { return true }
            return idea.title.lowercased().contains(searchText.lowercased())
        }
        
        scriptsCollectionView.reloadData()
        
        // Update empty state based on search results if searching
        if isFiltering {
            if pageTitle == "Your Scripts" && filteredMyScripts.isEmpty {
                showEmptyView(message: "No results found", iconName: "magnifyingglass")
                scriptsCollectionView.backgroundView?.isHidden = false
            } else if pageTitle != "Your Scripts" && filteredLikedIdeas.isEmpty {
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
