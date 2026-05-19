import UIKit

class InsightsViewController: UIViewController {
    @IBOutlet var insightIdeaView: UICollectionView!

    var ideas: [Idea] = []
    var analyticsIdeas: [AnalyticsIdea] = []

    var savedIdeaIDs: Set<UUID> = []
    var selectedIdea: Idea?

    var audienceMetrics: AudienceMetrics?
    var latestContent: [LatestContent] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        insightIdeaView.delegate = self
        insightIdeaView.dataSource = self
        insightIdeaView.register(PremiumIdeaCell.self, forCellWithReuseIdentifier: PremiumIdeaCell.identifier)
        insightIdeaView.register(UINib(nibName: "IdeaCells", bundle: nil), forCellWithReuseIdentifier: "ideaCell")
        insightIdeaView.setCollectionViewLayout(generateLayout(), animated: true)

        // Ensure collection view goes to the top, under safe area
        insightIdeaView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 40, right: 0)

        fetchData()
    }

    private func fetchData() {
        Task {
            await MainActor.run {
                OpaqueLoadingScreen.shared.show(message: "Generating Video Ideas...")
            }

            do {
                let channel = ChannelMetricsPayload(
                    id: SessionManager.shared.currentUser?.uid ?? UUID().uuidString,
                    title: "My Channel",
                    niche: SessionManager.shared.userPreferences?.niche.first?.rawValue ?? "General",
                    subscribers: audienceMetrics?.subscribers ?? 0,
                    postingFrequencyPerWeek: 3,
                    audienceGeo: []
                )

                let videos = latestContent.map { video in
                    GroqVideoPayload(
                        title: video.title,
                        views: video.views,
                        likes: video.likes,
                        comments: 0,
                        duration: video.durationSeconds,
                        publishedAt: ISO8601DateFormatter().string(from: video.publishedAt)
                    )
                }

                let payload = YoutubeIdeaGeneratorPayload(
                    analytics: audienceMetrics,
                    videos: videos,
                    channel: channel
                )

                let generatedIdeas = try await YouTubeController.shared.generateIdeas(payload: payload)

                await MainActor.run {
                    self.analyticsIdeas = generatedIdeas
                    self.insightIdeaView.reloadData()
                }
            } catch {
                print("Failed to generate ideas:", error)
                // Fallback
                await SessionManager.shared.restoreSession()

                await MainActor.run {
                    self.ideas = SessionManager.shared.personalizedIdeas
                    self.insightIdeaView.reloadData()
                }
            }
            await MainActor.run {
                OpaqueLoadingScreen.shared.hide()
            }
        }
    }

    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(120)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: itemSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 10, leading: 0, bottom: 10, trailing: 0
            )
            section.interGroupSpacing = 15

            return section
        }
    }
}

extension InsightsViewController: UICollectionViewDelegate, UICollectionViewDataSource, PremiumIdeaCellDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return analyticsIdeas.isEmpty ? ideas.count : analyticsIdeas.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if !analyticsIdeas.isEmpty {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PremiumIdeaCell.identifier,
                for: indexPath
            ) as? PremiumIdeaCell else {
                return UICollectionViewCell()
            }
            let analyticsIdea = analyticsIdeas[indexPath.row]
            cell.configure(with: analyticsIdea, isSaved: savedIdeaIDs.contains(analyticsIdea.id))
            cell.delegate = self
            return cell
        } else {
            // Fallback for old ideas. Also use PremiumIdeaCell
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PremiumIdeaCell.identifier,
                for: indexPath
            ) as? PremiumIdeaCell else {
                return UICollectionViewCell()
            }
            let idea = ideas[indexPath.row]
            cell.configure(with: idea)
            cell.delegate = self
            return cell
        }
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !analyticsIdeas.isEmpty {
            let selectedIdea = analyticsIdeas[indexPath.row]
            let vc = AnalyticsIdeaDetailViewController()
            vc.analyticsIdea = selectedIdea
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let selectedIdea = ideas[indexPath.row]
            let storyboard = UIStoryboard(name: "ViewIdea", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "IdeaVC") as? ViewIdea else {
                return
            }
            vc.idea = selectedIdea
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func didToggleLike(for cell: PremiumIdeaCell) {
        guard let indexPath = insightIdeaView.indexPath(for: cell) else { return }
        guard !analyticsIdeas.isEmpty else { return }

        let analyticsIdea = analyticsIdeas[indexPath.row]
        let isCurrentlySaved = savedIdeaIDs.contains(analyticsIdea.id)

        // Convert AnalyticsIdea → Idea so we can use the existing LikedIdeasController
        let ideaKey = makeIdeaKey(
            title: analyticsIdea.title,
            description: analyticsIdea.hook,
            format: analyticsIdea.format,
            hashtags: []
        )
        let idea = Idea(
            id: analyticsIdea.id,
            ideaKey: ideaKey,
            title: analyticsIdea.title,
            description: analyticsIdea.hook,
            format: analyticsIdea.format,
            hashtags: [],
            noveltyScore: Int(analyticsIdea.estimatedViralityScore),
            videos: nil,
            liked: !isCurrentlySaved
        )

        let likedIdeasController = LikedIdeasController()

        Task {
            do {
                if isCurrentlySaved {
                    // UNLIKE — remove from DB
                    try await likedIdeasController.unlikeIdea(ideaKey: ideaKey)
                    LikedIds.likedIdeaIds.remove(ideaKey)

                    // Remove from SessionManager if present
                    SessionManager.shared.personalizedIdeas.removeAll { $0.ideaKey == ideaKey }

                } else {
                    // LIKE — save to DB
                    try await likedIdeasController.likeIdea(idea)
                    LikedIds.likedIdeaIds.insert(ideaKey)

                    // Add to SessionManager so home screen can show it
                    if !SessionManager.shared.personalizedIdeas.contains(where: { $0.ideaKey == ideaKey }) {
                        SessionManager.shared.personalizedIdeas.insert(idea, at: 0)
                    }

                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }

                await MainActor.run {
                    if isCurrentlySaved {
                        self.savedIdeaIDs.remove(analyticsIdea.id)
                        CapsuleNotification.show(message: "Idea removed", iconName: "bookmark.slash")
                    } else {
                        self.savedIdeaIDs.insert(analyticsIdea.id)
                        CapsuleNotification.show(message: "Idea saved!", iconName: "bookmark.fill")
                    }
                    self.insightIdeaView.reloadItems(at: [indexPath])

                    // Notify home screen to sync
                    NotificationCenter.default.post(name: .didUpdateLikedStatus, object: ideaKey)
                }

            } catch {
                print("❌ Analytics idea save/unsave failed:", error)
                await MainActor.run {
                    CapsuleNotification.show(message: "Failed to save idea", iconName: "xmark.circle")
                }
            }
        }
    }
}
