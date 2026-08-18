import UIKit

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension Ideate1: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in _: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .search:    return 0
        case .chatbot:   return 1
        case .liked:     return likedIdeas.count
        case .recent:    return recentScripts.count
        case .suggested: return ideas.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case .chatbot:   return makeChatbotCell(collectionView, indexPath)
        case .liked:     return makeLikedCell(collectionView, indexPath)
        case .recent:    return makeRecentCell(collectionView, indexPath)
        case .suggested: return makeSuggestedCell(collectionView, indexPath)
        default:         return UICollectionViewCell()
        }
    }

    private func makeChatbotCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatbotAssistant", for: indexPath)
        cell.applyLiquidGlassEffect()
        return cell
    }

    private func makeLikedCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "likedCellsNew", for: indexPath
        ) as? LikedCellsNew else { return UICollectionViewCell() }
        let idea = likedIdeas[indexPath.row]
        cell.configureCell(idea: idea)
        cell.delegate = self
        cell.likeButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        return cell
    }

    private func makeRecentCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "scriptCellIdeate", for: indexPath
        ) as? ScriptCellIdeate else { return UICollectionViewCell() }
        if indexPath.row >= recentScripts.count {
            print("❌ Index out of range prevented")
            print("indexPath.row:", indexPath.row)
            print("recentScripts.count:", recentScripts.count)
            return cell
        }
        let script = recentScripts[indexPath.row]
        print("✅ Configuring recent script at index:", indexPath.row)
        cell.configureCell(with: script)
        return cell
    }

    private func makeSuggestedCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ideaCell", for: indexPath
        ) as? IdeaCells else { return UICollectionViewCell() }
        cell.configure(idea: ideas[indexPath.row])
        cell.delegate = self
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        switch sections[indexPath.section] {
        case .search:    return makeSearchHeader(collectionView, kind, indexPath)
        case .liked:     return makeLikedHeader(collectionView, kind, indexPath)
        case .recent:    return makeRecentHeader(collectionView, kind, indexPath)
        case .suggested: return makeSuggestedHeader(collectionView, kind, indexPath)
        default:         return UICollectionReusableView()
        }
    }

    private func makeSearchHeader(
        _ collectionView: UICollectionView, _ kind: String, _ indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: "IdeaSearch", for: indexPath
        ) as? IdeaSearch else { return UICollectionReusableView() }
        header.configure(state: .ideateMain)
        header.delegate = self
        return header
    }

    private func makeLikedHeader(
        _ collectionView: UICollectionView, _ kind: String, _ indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath
        ) as? HeaderView else { return UICollectionReusableView() }
        header.configureHeader(text: "Saved Ideas")
        header.showChevron(true)
        header.didTapChevron = { [weak self] in
            let storyboard = UIStoryboard(name: "ViewScripts", bundle: nil)
            guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController else { return }
            guard let destinationVC = navVC.topViewController as? ViewScriptsViewController else { return }
            destinationVC.pageTitle = "Saved Ideas"
            self?.navigationController?.pushViewController(destinationVC, animated: true)
        }
        return header
    }

    private func makeRecentHeader(
        _ collectionView: UICollectionView, _ kind: String, _ indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath
        ) as? HeaderView else { return UICollectionReusableView() }
        header.configureHeader(text: "Generated Posts")
        header.showChevron(true)
        header.didTapChevron = { [weak self] in
            let storyboard = UIStoryboard(name: "ViewScripts", bundle: nil)
            guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController else { return }
            guard let destinationVC = navVC.topViewController as? ViewScriptsViewController else { return }
            destinationVC.pageTitle = "Your Scripts"
            self?.navigationController?.pushViewController(destinationVC, animated: true)
        }
        return header
    }

    private func makeSuggestedHeader(
        _ collectionView: UICollectionView, _ kind: String, _ indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath
        ) as? HeaderView else { return UICollectionReusableView() }
        header.configureHeader(text: "Suggested For You")
        header.showChevron(false)
        header.isHidden = isSearching
        return header
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .chatbot:   navigateToChatbot()
        case .liked:     navigateToLikedIdea(at: indexPath)
        case .recent:    navigateToRecentScript(at: indexPath)
        case .suggested: navigateToSuggestedIdea(at: indexPath)
        default:         break
        }
    }

    private func navigateToChatbot() {
        let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)
        guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController,
              let chatbotVC = navVC.topViewController as? Chatbot else { return }
        navigationController?.pushViewController(chatbotVC, animated: true)
    }

    private func navigateToLikedIdea(at indexPath: IndexPath) {
        if indexPath.row >= likedIdeas.count {
            print("❌ Liked index out of range")
            print("index:", indexPath.row)
            print("likedIdeas.count:", likedIdeas.count)
            return
        }
        let idea = likedIdeas[indexPath.row]
        let storyboard = UIStoryboard(name: "ViewIdea", bundle: nil)
        if let destinationVC = storyboard.instantiateViewController(withIdentifier: "IdeaVC") as? ViewIdea {
            destinationVC.idea = idea
            navigationController?.pushViewController(destinationVC, animated: true)
        }
    }

    private func navigateToRecentScript(at indexPath: IndexPath) {
        let script = recentScripts[indexPath.row]
        if let ideaId = script.ideaId {
            let storyboard = UIStoryboard(name: "ViewIdea", bundle: nil)
            if let destinationVC = storyboard.instantiateViewController(withIdentifier: "IdeaVC") as? ViewIdea {
                destinationVC.ideaId = ideaId
                navigationController?.pushViewController(destinationVC, animated: true)
            }
        } else {
            let storyboard = UIStoryboard(name: "Ideate", bundle: nil)
            if let destinationVC = storyboard.instantiateViewController(
                withIdentifier: "scriptedIdea"
            ) as? ScriptedIdeas {
                destinationVC.idea = script
                navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }

    private func navigateToSuggestedIdea(at indexPath: IndexPath) {
        let idea = ideas[indexPath.row]
        let storyboard = UIStoryboard(name: "ViewIdea", bundle: nil)
        guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController else { return }
        guard let destinationVC = navVC.topViewController as? ViewIdea else { return }
        destinationVC.idea = idea
        navigationController?.pushViewController(destinationVC, animated: true)
    }
}
