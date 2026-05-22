import Charts
import Supabase
import SwiftUI
import UIKit

class ViewIdea: UIViewController {
    @IBOutlet var ideaView: UICollectionView!

    var idea: Idea?
    var video: [Video] = []
    var ideaId: UUID?
    var hasExistingScript: Bool = false
    var ideaMilestone: Int = 0
    var completedScriptTypes: Set<String> = []
    var hasStartedConversation: Bool = false
    var currentConversationID: UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        ideaView.delegate = self
        ideaView.dataSource = self
        ideaView.setCollectionViewLayout(generateLayout(), animated: true)
        if idea == nil, let ideaId = ideaId {
            // First try local cache
            idea = SessionManager.shared.personalizedIdeas.first(where: { $0.id == ideaId })

            // If not found locally, fetch from Supabase
            if idea == nil {
                fetchIdeaFromSupabase(ideaId: ideaId)
            }
        }

        // Enrich idea with full video/hashtag data from local cache if it came
        // from liked_ideas (which strips videos to nil on fetch)
        if let current = idea, current.videos == nil, let ideaKey = current.ideaKey {
            if let enriched = SessionManager.shared.personalizedIdeas
                .first(where: { $0.ideaKey == ideaKey }) {
                // Preserve liked state but use full data
                var full = enriched
                full.liked = current.liked
                idea = full
            }
        }
    }

    private func fetchIdeaFromSupabase(ideaId: UUID) {
        Task {
            do {
                // Try fetching from the ideas table directly
                let result: [IdeaFromDB] = try await SupabaseConfig.client.database
                    .from("ideas")
                    .select()
                    .eq("id", value: ideaId.uuidString)
                    .limit(1)
                    .execute()
                    .value

                if let fetched = result.first {
                    var idea = Idea(
                        id: fetched.id,
                        ideaKey: nil,
                        title: fetched.title,
                        description: fetched.description ?? "",
                        format: fetched.format ?? "",
                        hashtags: fetched.hashtags ?? [],
                        noveltyScore: fetched.noveltyScore ?? 0,
                        videos: nil,
                        liked: false
                    )

                    // Enrich with full video/hashtag data from local cache or liked_ideas
                    if let enriched = SessionManager.shared.personalizedIdeas
                        .first(where: { $0.title == fetched.title }) {
                        idea = Idea(
                            id: fetched.id,
                            ideaKey: enriched.ideaKey,
                            title: enriched.title,
                            description: enriched.description,
                            format: enriched.format,
                            hashtags: enriched.hashtags,
                            noveltyScore: enriched.noveltyScore,
                            videos: enriched.videos,
                            liked: enriched.liked
                        )
                    } else {
                        // Try enriching from liked_ideas (which has stored views/likes)
                        let likedIdeas = try await LikedIdeasController().fetchLikedIdeas()
                        if let likedMatch = likedIdeas.first(where: { $0.title == fetched.title }) {
                            idea = likedMatch
                        }
                    }

                    await MainActor.run {
                        self.idea = idea
                        self.ideaView.reloadData()
                        self.checkForExistingScript()
                    }
                    return
                }

                // Fallback: try fetching from liked_ideas
                let likedIdeas = try await LikedIdeasController().fetchLikedIdeas()
                if let matched = likedIdeas.first(where: { $0.id == ideaId }) {
                    await MainActor.run {
                        self.idea = matched
                        self.ideaView.reloadData()
                        self.checkForExistingScript()
                    }
                }
            } catch {
                print("⚠️ Failed to fetch idea from Supabase:", error)
            }
        }
    }

    func checkForExistingScript() {
        guard let idea = idea else { return }
        Task {
            do {
                let controller = ScriptedIdeasController()
                var script = try await controller.fetchScriptByIdeaId(ideaId: idea.id)
                var conversation = try await controller.fetchConversation(for: idea.id)

                // Fallback: if not found by idea.id (e.g. liked_ideas gives random UUIDs),
                // look up the real UUID from the ideas table by matching title
                if script == nil && conversation == nil {
                    let matchingIdeas: [IdeaFromDB] = try await SupabaseConfig.client.database
                        .from("ideas")
                        .select()
                        .eq("title", value: idea.title)
                        .limit(1)
                        .execute()
                        .value

                    if let realIdea = matchingIdeas.first, realIdea.id != idea.id {
                        script = try await controller.fetchScriptByIdeaId(ideaId: realIdea.id)
                        conversation = try await controller.fetchConversation(for: realIdea.id)

                        // Update our idea's reference so Draft Script also works correctly
                        await MainActor.run {
                            self.idea = Idea(
                                id: realIdea.id,
                                ideaKey: idea.ideaKey,
                                title: idea.title,
                                description: idea.description,
                                format: idea.format,
                                hashtags: idea.hashtags,
                                noveltyScore: idea.noveltyScore,
                                videos: idea.videos,
                                expandedDescription: idea.expandedDescription,
                                liked: idea.liked
                            )
                        }
                    }
                }

                await MainActor.run {
                    self.hasExistingScript = script != nil
                    self.hasStartedConversation = conversation != nil
                    self.currentConversationID = conversation?.id

                    if let script = script {
                        var types: Set<String> = []
                        if let s = script.script, !s.isEmpty { types.insert("script") }
                        if let t = script.title, !t.isEmpty { types.insert("title") }
                        if let d = script.description, !d.isEmpty { types.insert("description") }
                        self.completedScriptTypes = types
                        self.ideaMilestone = types.count
                    } else {
                        self.completedScriptTypes = []
                        self.ideaMilestone = 0
                    }

                    self.ideaView.reloadSections(IndexSet(integer: 0))
                }
            } catch {
                print("Failed to fetch script:", error)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForExistingScript()
    }

    @IBAction func draftTap(_: Any) {
        guard let idea = idea else { return }
        didTapDraftScript(for: idea)
    }

    func didTapDraftScript(for idea: Idea, conversationID: UUID? = nil) {
        Task {
            do {
                try await ScriptedIdeasController().insertIdeaIfNeeded(idea: idea)
            } catch {
                print("⚠️ Failed to insert idea:", error)
            }

            await MainActor.run {
                let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)
                guard let chatVC = storyboard.instantiateViewController(
                    withIdentifier: "Chatbot"
                ) as? Chatbot else { return }
                chatVC.ideaId = idea.id
                if let conversationID = conversationID {
                    chatVC.conversationID = conversationID
                } else {
                    chatVC.autoSendMessage = """
                    Create a short creator-style script for this video idea:

                    Title: "\(idea.title)"
                    Description: "\(idea.description)"

                    Structure:
                    1. Hook (1 sentence)
                    2. What happens (2–3 sentences)
                    3. Twist or surprise (1 sentence)
                    4. CTA (1 sentence)

                    Tone: casual, friendly, modern.
                    Length: 15–20 seconds.
                    """
                }
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
        }
    }

    func handleDraftScriptTap(for idea: Idea) {
        Task {
            do {
                let existing = try await ScriptedIdeasController()
                    .fetchScriptByIdeaId(ideaId: idea.id)
                let existingConversation = try await ScriptedIdeasController()
                    .fetchConversation(for: idea.id)

                DispatchQueue.main.async {
                    if let existingScript = existing {
                        // Script exists — go straight to it
                        let storyboard = UIStoryboard(name: "Ideate", bundle: nil)
                        guard let vc = storyboard.instantiateViewController(
                            withIdentifier: "scriptedIdea"
                        ) as? ScriptedIdeas else { return }
                        vc.idea = existingScript
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else if let conversation = existingConversation {
                        self.didTapDraftScript(for: idea, conversationID: conversation.id)
                    } else {
                        // No script yet — go to chatbot
                        self.didTapDraftScript(for: idea)
                    }
                }
            } catch {
                // Fallback to chatbot if fetch fails
                DispatchQueue.main.async { self.didTapDraftScript(for: idea) }
            }
        }
    }

    func registerCell() {
        ideaView.register(
            UINib(
                nibName: "HeaderView",
                bundle: nil
            ),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "headerCell"
        )

        ideaView.register(
            UINib(nibName: "IdeaProgressCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "cell"
        )
    }

    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { section, _ in
            switch section {
            case 0: return self.progressCardLayout()
            case 1: return self.basicInfoLayout()
            case 2:
                if self.shouldShowStats() {
                    return self.statisticsLayout()
                }
                return self.emptyLayout()
            case 3:
                if self.shouldShowHashtags() {
                    return self.hashtagLayout()
                }
                return self.emptyLayout()
            default:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(0.25)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize, repeatingSubitem: item, count: 7
                )
                let sec = NSCollectionLayoutSection(group: group)
                sec.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
                return sec
            }
        }
    }

    private func shouldShowStats() -> Bool {
        let stats = idea.flatMap { statistics(with: $0) } ?? []
        return !stats.isEmpty
    }

    private func shouldShowHashtags() -> Bool {
        return !(idea?.hashtags ?? []).isEmpty
    }

    private func emptyLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }

    private func progressCardLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(140)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 15, trailing: 20)
        return section
    }

    private func basicInfoLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        return section
    }

    private func statisticsLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.45),
            heightDimension: .estimated(110)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50)
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize, elementKind: "header", alignment: .top
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [headerItem]
        return section
    }

    private func hashtagLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(70)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50)
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize, elementKind: "header", alignment: .top
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        section.boundarySupplementaryItems = [headerItem]
        return section
    }

    func statistics(with idea: Idea) -> [Int] {
        guard let videos = idea.videos, !videos.isEmpty else {
            print("No videos available")
            return []
        }

        // Convert totals into Double
        let totalViews = videos.reduce(0) { $0 + $1.views }
        let totalLikes = videos.reduce(0) { $0 + $1.likes }

        let count = videos.count

        let avgViews = totalViews / count
        let avgLikes = totalLikes / count

        return [avgViews, avgLikes]
    }
}

extension ViewIdea: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in _: UICollectionView) -> Int {
        if !shouldShowStats() && !shouldShowHashtags() {
            return 2 // Only show draft status (0) and basic info (1)
        }
        return 5
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 2 {
            if !shouldShowStats() { return 0 }
            return 2
        }
        if section == 3 {
            if !shouldShowHashtags() { return 0 }
            return 1
        }
        return 1
    }

    func collectionView(_: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = ideaView
                .dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? IdeaProgressCollectionViewCell
            else {
                return UICollectionViewCell()
            }

            _ = Set(
                [("script", ideaMilestone >= 1), ("title", ideaMilestone >= 2), ("description", ideaMilestone >= 3)]
                    .filter { $0.1 }.map { $0.0 }
            )
            let title: String
            if hasExistingScript {
                title = "View Draft"
            } else if hasStartedConversation {
                title = "Continue"
            } else {
                title = "Draft Script"
            }

            cell.configure(
                completedTypes: completedScriptTypes,
                buttonTitle: title
            )
            cell.onButtonTapped = { [weak self] in
                guard let self = self, let idea = self.idea else { return }
                self.handleDraftScriptTap(for: idea)
            }
            return cell
        } else if indexPath.section == 1 {
            guard let cell = ideaView
                .dequeueReusableCell(
                    withReuseIdentifier: "basicInfo",
                    for: indexPath
                ) as? IdeaDetailsCollectionViewCell
            else {
                return UICollectionViewCell()
            }
            if let idea = idea {
                cell.configure(with: idea)
            }
            cell.onContentUpdated = { [weak self] in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    self.ideaView.performBatchUpdates(nil)
                }
            }

            return cell
        } else if indexPath.section == 2 {
            guard let cell = ideaView
                .dequeueReusableCell(
                    withReuseIdentifier: "statistics",
                    for: indexPath
                ) as? IdeaDetailsCollectionViewCell
            else {
                return UICollectionViewCell()
            }

            guard let idea = idea else { return cell }

            // Use your existing stats function
            let values = statistics(with: idea)

            // Safe guard
            guard indexPath.row < values.count else { return cell }

            // Labels match values
            let symbols = ["eye", "hand.thumbsup"]

            let value = values[indexPath.row]
            let symbol = symbols[indexPath.row]

            cell.configureStatistic(value, symbol)
            cell.view.layer.cornerRadius = 16
            cell.view.layer.borderWidth = 0.5
            cell.view.backgroundColor = UIColor.accent.withAlphaComponent(0.1)
            cell.view.layer.borderColor = UIColor.accent.withAlphaComponent(1.0).cgColor
            return cell
        } else if indexPath.section == 3 {
            guard let cell = ideaView
                .dequeueReusableCell(withReuseIdentifier: "gaps", for: indexPath) as? IdeaDetailsCollectionViewCell
            else {
                return UICollectionViewCell()
            }

            cell.configureHashtag(idea?.hashtags ?? [])
            return cell
        }

        guard let cell = ideaView
            .dequeueReusableCell(withReuseIdentifier: "button", for: indexPath) as? IdeaDetailsCollectionViewCell
        else {
            return UICollectionViewCell()
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == "header", indexPath.section == 2 {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: "header",
                withReuseIdentifier: "headerCell",
                for: indexPath
            ) as? HeaderView else {
                return UICollectionReusableView()
            }

            headerView.configureHeader(text: "Performance Statistics")
            return headerView
        } else if kind == "header", indexPath.section == 3 {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: "header",
                withReuseIdentifier: "headerCell",
                for: indexPath
            ) as? HeaderView else {
                return UICollectionReusableView()
            }

            headerView.configureHeader(text: "Trending Hashtags")
            return headerView
        }
        return UICollectionReusableView()
    }
}
