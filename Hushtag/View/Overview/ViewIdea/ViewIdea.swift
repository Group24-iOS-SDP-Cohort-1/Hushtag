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
            idea = SessionManager.shared.personalizedIdeas.first(where: { $0.id == ideaId })
            if idea == nil {
                fetchIdeaFromSupabase(ideaId: ideaId)
            }
        }
        enrichIdeaFromCache()
    }

    private func enrichIdeaFromCache() {
        guard let current = idea, current.videos == nil, let ideaKey = current.ideaKey else { return }
        if let enriched = SessionManager.shared.personalizedIdeas
            .first(where: { $0.ideaKey == ideaKey }) {
            var full = enriched
            full.liked = current.liked
            idea = full
        }
    }

    private func fetchIdeaFromSupabase(ideaId: UUID) {
        Task {
            do {
                let result: [IdeaFromDB] = try await SupabaseConfig.client.database
                    .from("ideas")
                    .select()
                    .eq("id", value: ideaId.uuidString)
                    .limit(1)
                    .execute()
                    .value

                if let fetched = result.first {
                    await handleFetchedIdea(fetched)
                    return
                }

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

    private func handleFetchedIdea(_ fetched: IdeaFromDB) async {
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
            let likedIdeas = try? await LikedIdeasController().fetchLikedIdeas()
            if let likedMatch = likedIdeas?.first(where: { $0.title == fetched.title }) {
                idea = likedMatch
            }
        }

        await MainActor.run {
            self.idea = idea
            self.ideaView.reloadData()
            self.checkForExistingScript()
        }
    }
    func checkForExistingScript() {
        guard let idea = idea else { return }
        Task {
            do {
                let controller = ScriptedIdeasController()
                var script = try await controller.fetchScriptByIdeaId(ideaId: idea.id)
                var conversation = try await controller.fetchConversation(for: idea.id)

                if script == nil && conversation == nil {
                    try await resolveScriptViaTitle(
                        idea: idea, controller: controller,
                        script: &script, conversation: &conversation
                    )
                }

                await MainActor.run {
                    self.hasExistingScript = script != nil
                    self.hasStartedConversation = conversation != nil
                    self.currentConversationID = conversation?.id
                    self.completedScriptTypes = script.map { resolveScriptTypes(from: $0) } ?? []
                    self.ideaMilestone = self.completedScriptTypes.count
                    self.ideaView.reloadSections(IndexSet(integer: 0))
                }
            } catch {
                print("Failed to fetch script:", error)
            }
        }
    }

    private func resolveScriptViaTitle(
        idea: Idea,
        controller: ScriptedIdeasController,
        script: inout ScriptedIdea?,
        conversation: inout Conversation?
    ) async throws {
        let matchingIdeas: [IdeaFromDB] = try await SupabaseConfig.client.database
            .from("ideas")
            .select()
            .eq("title", value: idea.title)
            .limit(1)
            .execute()
            .value

        guard let realIdea = matchingIdeas.first, realIdea.id != idea.id else { return }
        script = try await controller.fetchScriptByIdeaId(ideaId: realIdea.id)
        conversation = try await controller.fetchConversation(for: realIdea.id)

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
                        let storyboard = UIStoryboard(name: "Ideate", bundle: nil)
                        guard let scriptedIdeasVC = storyboard.instantiateViewController(
                            withIdentifier: "scriptedIdea"
                        ) as? ScriptedIdeas else { return }
                        scriptedIdeasVC.idea = existingScript
                        self.navigationController?.pushViewController(scriptedIdeasVC, animated: true)
                    } else if let conversation = existingConversation {
                        self.didTapDraftScript(for: idea, conversationID: conversation.id)
                    } else {
                        self.didTapDraftScript(for: idea)
                    }
                }
            } catch {
                DispatchQueue.main.async { self.didTapDraftScript(for: idea) }
            }
        }
    }

    func registerCell() {
        ideaView.register(
            UINib(nibName: "HeaderView", bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "headerCell"
        )
        ideaView.register(
            UINib(nibName: "IdeaProgressCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "cell"
        )
    }

    // MARK: - Layout methods extracted to ViewIdea+Layout.swift
    func statistics(with idea: Idea) -> [Int] {
        guard let videos = idea.videos, !videos.isEmpty else {
            print("No videos available")
            return []
        }
        let totalViews = videos.reduce(0) { $0 + $1.views }
        let totalLikes = videos.reduce(0) { $0 + $1.likes }
        let count = videos.count
        return [totalViews / count, totalLikes / count]
    }
}

// MARK: - Private Helpers

private func resolveScriptTypes(from script: ScriptedIdea) -> Set<String> {
    var types: Set<String> = []
    if let scriptText = script.script, !scriptText.isEmpty { types.insert("script") }
    if let titleText = script.title, !titleText.isEmpty { types.insert("title") }
    if let descriptionText = script.description, !descriptionText.isEmpty { types.insert("description") }
    return types
}
