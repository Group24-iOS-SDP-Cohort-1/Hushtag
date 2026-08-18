import UIKit

extension ViewScriptsViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if pageTitle == "Chat History" || pageTitle == "Your Scripts" {
            // If searching, use filtered list. Else, use full list.
            return isFiltering ? filteredMyScripts.count : myScripts.count
        } else {
            return isFiltering ? filteredLikedIdeas.count : likedIdeas.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if pageTitle == "Chat History" || pageTitle == "Your Scripts" {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "scriptedIdeas",
                for: indexPath
            ) as? ScriptsCell1 else {
                return UICollectionViewCell()
            }

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
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "likedCellsNew", for: indexPath) as? LikedCellsNew
        else {
            return UICollectionViewCell()
        }

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

func generateScriptsLayout(title: String) -> UICollectionViewLayout {
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

    return UICollectionViewCompositionalLayout(section: section)
}

extension ViewScriptsViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if pageTitle == "Chat History" || pageTitle == "Your Scripts" {
            // Get the correct script based on search state
            let script: ScriptedIdea
            if isFiltering {
                script = filteredMyScripts[indexPath.row]
            } else {
                script = myScripts[indexPath.row]
            }

            let storyboard = UIStoryboard(name: "Ideate", bundle: nil)
            if let destinationVC = storyboard
                .instantiateViewController(withIdentifier: "scriptedIdea") as? ScriptedIdeas {
                destinationVC.idea = script
                navigationController?.pushViewController(destinationVC, animated: true)
            }
            return
        }

        let idea: Idea
        if isFiltering {
            idea = filteredLikedIdeas[indexPath.row]
        } else {
            idea = likedIdeas[indexPath.row]
        }

        let storyboard = UIStoryboard(name: "ViewIdea", bundle: nil)
        if let destinationVC = storyboard.instantiateViewController(withIdentifier: "IdeaVC") as? ViewIdea {
            destinationVC.idea = idea
            navigationController?.pushViewController(destinationVC, animated: true)
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
                let likedIdeasController = LikedIdeasController()
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

                let likedIdeasController = LikedIdeasController()
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

                    guard let viewController = storyboard.instantiateViewController(
                        withIdentifier: "Chatbot"
                    ) as? Chatbot else { return }

                    viewController.conversationID = finalConvoId

                    if isNew {
                        viewController.autoSendMessage = """
                        Generate a short engaging social media video script.

                        Idea Title: \(idea.title)

                        Idea Description: \(idea.description)

                        The script should include:
                        - Hook
                        - Main content
                        - Ending CTA
                        """
                    }

                    self.navigationController?.pushViewController(viewController, animated: true)
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
            if pageTitle == "Chat History" || pageTitle == "Your Scripts", filteredMyScripts.isEmpty {
                showEmptyView(message: "No results found", iconName: "magnifyingglass")
                scriptsCollectionView.backgroundView?.isHidden = false
            } else if pageTitle != "Chat History", filteredLikedIdeas.isEmpty {
                showEmptyView(message: "No results found", iconName: "magnifyingglass")
                scriptsCollectionView.backgroundView?.isHidden = false
            } else {
                scriptsCollectionView.backgroundView = nil
            }
        } else {
            updateEmptyState()
        }
    }

    /// Helper to determine if we are currently filtering
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
}
