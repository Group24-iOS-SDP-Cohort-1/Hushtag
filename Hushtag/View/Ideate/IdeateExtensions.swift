import Foundation
import UIKit

extension Ideate1: IdeaCellDelegate {
    func didToggleLikeFromFeed(for ideaKey: String) {
        let foundIdea = ideas.first(where: { $0.ideaKey == ideaKey }) ?? likedIdeas
            .first(where: { $0.ideaKey == ideaKey })

        guard var idea = foundIdea else {
            print("❌ Idea not found")
            return
        }

        let isCurrentlyLiked = LikedIds.likedIdeaIds.contains(ideaKey)

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
                    idea.liked = !isCurrentlyLiked

                    // Keep SessionManager in sync (VERY important)
                    if let smIndex = SessionManager.shared.personalizedIdeas
                        .firstIndex(where: { $0.ideaKey == ideaKey }) {
                        SessionManager.shared.personalizedIdeas[smIndex].liked = !isCurrentlyLiked
                    }
                    let willCreateSection = self.likedIdeas.isEmpty && !isCurrentlyLiked
                    let willDestroySection = self.likedIdeas.count == 1 && isCurrentlyLiked

                    if willCreateSection || willDestroySection {
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
                        return
                    }

                    guard let likedSectionIndex = self.sections.firstIndex(of: .liked),
                          let suggestedSectionIndex = self.sections.firstIndex(of: .suggested)
                    else {
                        if isCurrentlyLiked {
                            self.likedIdeas.removeAll { $0.ideaKey == ideaKey }
                            self.ideas.removeAll { $0.ideaKey == ideaKey }
                            self.ideas.insert(idea, at: 0)
                        } else {
                            self.ideas.removeAll { $0.ideaKey == ideaKey }
                            self.likedIdeas.removeAll { $0.ideaKey == ideaKey }
                            self.likedIdeas.insert(idea, at: 0)
                        }
                        self.collectionView.reloadData()
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

            } catch {
                print("❌ Like toggle failed:", error)
            }
        }
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

extension Ideate1: LikedCellDelegate {
    func didTapDraftScript(for idea: Idea) {
        print("Draft tapped:", idea.title)
        // you already handle this elsewhere probably
    }

    func didToggleLike(for ideaKey: String) {
        // reuse SAME logic as suggested toggle
        didToggleLikeFromFeed(for: ideaKey)
    }
}
