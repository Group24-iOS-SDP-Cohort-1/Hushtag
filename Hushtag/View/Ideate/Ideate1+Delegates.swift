import UIKit

// MARK: - IdeaSearchDelegate

extension Ideate1: IdeaSearchDelegate {
    func didTapSearch(with keyword: String) {
        if keyword.isEmpty {
            isSearching = false
            ideas = syncLikedState(SessionManager.shared.personalizedIdeas)
            collectionView.reloadData()
            return
        }

        let storyboard = UIStoryboard(name: "Ideate", bundle: nil)
        if let searchVC = storyboard.instantiateViewController(
            withIdentifier: "AfterSearchIdeasViewController"
        ) as? AfterSearchIdeasViewController {
            searchVC.keyword = keyword
            navigationController?.pushViewController(searchVC, animated: true)
        }
    }
}

// MARK: - IdeaCellDelegate

extension Ideate1: IdeaCellDelegate {
    func didToggleLikeFromFeed(for ideaKey: String) {
        let foundIdea = ideas.first(where: { $0.ideaKey == ideaKey })
            ?? likedIdeas.first(where: { $0.ideaKey == ideaKey })

        guard var idea = foundIdea else {
            print("❌ Idea not found")
            return
        }

        let isCurrentlyLiked = LikedIds.likedIdeaIds.contains(ideaKey)

        Task {
            do {
                if isCurrentlyLiked {
                    try await likedIdeasController.unlikeIdea(ideaKey: ideaKey)
                    LikedIds.likedIdeaIds.remove(ideaKey)
                } else {
                    try await likedIdeasController.likeIdea(idea)
                    LikedIds.likedIdeaIds.insert(ideaKey)
                }

                await MainActor.run {
                    idea.liked = !isCurrentlyLiked
                    self.syncSessionManager(ideaKey: ideaKey, isCurrentlyLiked: isCurrentlyLiked)
                    self.applyLikeUpdate(
                        idea: idea,
                        ideaKey: ideaKey,
                        isCurrentlyLiked: isCurrentlyLiked
                    )
                }
            } catch {
                print("❌ Like toggle failed:", error)
            }
        }
    }

    private func syncSessionManager(ideaKey: String, isCurrentlyLiked: Bool) {
        if let smIndex = SessionManager.shared.personalizedIdeas
            .firstIndex(where: { $0.ideaKey == ideaKey }) {
            SessionManager.shared.personalizedIdeas[smIndex].liked = !isCurrentlyLiked
        }
    }

    private func applyLikeUpdate(idea: Idea, ideaKey: String, isCurrentlyLiked: Bool) {
        let willCreateSection = self.likedIdeas.isEmpty && !isCurrentlyLiked
        let willDestroySection = self.likedIdeas.count == 1 && isCurrentlyLiked

        if willCreateSection || willDestroySection {
            applyFullReload(idea: idea, ideaKey: ideaKey, isCurrentlyLiked: isCurrentlyLiked)
            return
        }

        guard let likedSectionIndex = self.sections.firstIndex(of: .liked),
              let suggestedSectionIndex = self.sections.firstIndex(of: .suggested)
        else {
            applyFullReload(idea: idea, ideaKey: ideaKey, isCurrentlyLiked: isCurrentlyLiked)
            return
        }

        self.applyLikeToggleBatchUpdates(
            idea: idea,
            ideaKey: ideaKey,
            isCurrentlyLiked: isCurrentlyLiked,
            likedSection: likedSectionIndex,
            suggestedSection: suggestedSectionIndex
        )
    }

    private func applyFullReload(idea: Idea, ideaKey: String, isCurrentlyLiked: Bool) {
        if isCurrentlyLiked {
            self.likedIdeas.removeAll { $0.ideaKey == ideaKey }
            self.ideas.removeAll { $0.ideaKey == ideaKey }
            self.ideas.insert(idea, at: 0)
        } else {
            self.ideas.removeAll { $0.ideaKey == ideaKey }
            self.likedIdeas.removeAll { $0.ideaKey == ideaKey }
            self.likedIdeas.insert(idea, at: 0)
        }

        UIView.transition(
            with: self.collectionView,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { self.collectionView.reloadData() },
            completion: { _ in
                NotificationCenter.default.post(name: .didUpdateLikedStatus, object: ideaKey)
            }
        )
    }

    private func applyLikeToggleBatchUpdates(
        idea: Idea,
        ideaKey: String,
        isCurrentlyLiked: Bool,
        likedSection: Int,
        suggestedSection: Int
    ) {
        let oldIdeaRow = ideas.firstIndex(where: { $0.ideaKey == ideaKey })
        let oldLikedRow = likedIdeas.firstIndex(where: { $0.ideaKey == ideaKey })

        collectionView.performBatchUpdates({
            if isCurrentlyLiked {
                if let row = oldLikedRow {
                    self.likedIdeas.remove(at: row)
                    self.collectionView.deleteItems(at: [IndexPath(row: row, section: likedSection)])
                }
                if let row = oldIdeaRow {
                    self.ideas.remove(at: row)
                    self.collectionView.deleteItems(at: [IndexPath(row: row, section: suggestedSection)])
                }
                self.ideas.insert(idea, at: 0)
                self.collectionView.insertItems(at: [IndexPath(row: 0, section: suggestedSection)])
            } else {
                if let row = oldIdeaRow {
                    self.ideas.remove(at: row)
                    self.collectionView.deleteItems(at: [IndexPath(row: row, section: suggestedSection)])
                }
                if let row = oldLikedRow {
                    self.likedIdeas.remove(at: row)
                    self.collectionView.deleteItems(at: [IndexPath(row: row, section: likedSection)])
                }
                self.likedIdeas.insert(idea, at: 0)
                self.collectionView.insertItems(at: [IndexPath(row: 0, section: likedSection)])
            }
        }, completion: { _ in
            NotificationCenter.default.post(name: .didUpdateLikedStatus, object: ideaKey)
        })
    }
}

// MARK: - LikedCellDelegate

extension Ideate1: LikedCellDelegate {
    func didTapDraftScript(for idea: Idea) {
        print("Draft tapped:", idea.title)
    }

    func didToggleLike(for ideaKey: String) {
        didToggleLikeFromFeed(for: ideaKey)
    }
}
