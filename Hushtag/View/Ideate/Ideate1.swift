import UIKit

class Ideate1: UIViewController {
    var ideas: [Idea] = []
    var selectedIdea: Idea?
    var selectedIndexPath: IndexPath?
    let likedIdeasController = LikedIdeasController()
    var isSearching: Bool = false

    // NEW: Recent Scripts Data
    var recentScripts: [ScriptedIdea] = []
    var likedIdeas: [Idea] = []
    private let scriptsController = ScriptedIdeasController()
    @IBOutlet var collectionView: UICollectionView!

    @IBOutlet var profileImageView: UIImageView!
    private let profileController = ProfileController()

    enum SectionType {
        case search
        case chatbot
        case liked
        case recent
        case suggested
    }

    var sections: [SectionType] {
        var list: [SectionType] = [.search, .chatbot]
        if !likedIdeas.isEmpty { list.append(.liked) }
        if !recentScripts.isEmpty { list.append(.recent) }
        list.append(.suggested)
        return list
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchProfileButtonData()
        collectionView.reloadData()
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

        setupGlobalKeyboardDismiss()
        ideas = syncLikedState(SessionManager.shared.personalizedIdeas)
        fetchRecentScripts()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fetchProfileButtonData),
            name: .didUpdateProfile,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRecentScripts()
        syncLikedIdeas()
    }

    @objc func syncLikedIdeas() {
        Task {
            do {
                let fetchedLikedIdeas = try await likedIdeasController.fetchLikedIdeas()
                let personalizedIdeas = SessionManager.shared.personalizedIdeas
                let syncedLikedIdeas = fetchedLikedIdeas.map { liked in
                    if let personalized = personalizedIdeas.first(where: { $0.ideaKey == liked.ideaKey }) {
                        var updated = personalized
                        updated.liked = true
                        return updated
                    }
                    return liked
                }
                await MainActor.run {
                    self.likedIdeas = syncedLikedIdeas
                    self.collectionView.reloadData()
                }
            } catch {
                print("Failed to fetch liked ideas:", error)
            }
        }
    }

    private func fetchRecentScripts() {
        Task {
            do {
                let conversations = try await scriptsController.fetchConversations()
                let allScripts = conversations.compactMap { conversation -> ScriptedIdea? in
                    guard let dbScript = conversation.scriptedIdeas else { return nil }
                    return ScriptedIdea(
                        id: dbScript.id,
                        chatId: dbScript.chatId,
                        title: dbScript.title,
                        description: dbScript.description,
                        script: dbScript.script,
                        thumbnail: dbScript.thumbnail,
                        tags: dbScript.tags,
                        ideaId: conversation.ideaId
                    )
                }
                let top4 = Array(allScripts.prefix(4))
                await MainActor.run {
                    print("🔄 Updating recentScripts")
                    self.recentScripts = top4
                    DispatchQueue.main.async { self.collectionView.reloadData() }
                }
            } catch {
                print("Error fetching recent scripts: \(error)")
            }
        }
    }

    private func register() {
        collectionView.register(
            UINib(nibName: "IdeaCells", bundle: nil),
            forCellWithReuseIdentifier: "ideaCell"
        )
        collectionView.register(
            UINib(nibName: "LikedCellsNew", bundle: nil),
            forCellWithReuseIdentifier: "likedCellsNew"
        )
        collectionView.register(
            UINib(nibName: "Script_cell_ideate", bundle: nil),
            forCellWithReuseIdentifier: "scriptCellIdeate"
        )
        collectionView.register(
            UINib(nibName: "HeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "headerCell"
        )
        collectionView.register(
            UINib(nibName: "IdeaSearch", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "IdeaSearch"
        )
    }

    private func setupGlobalKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func handleLikeUpdate(_ notification: Notification) {
        guard let ideaKey = notification.object as? String,
              let index = ideas.firstIndex(where: { $0.ideaKey == ideaKey })
        else { return }

        ideas[index].liked = LikedIds.likedIdeaIds.contains(ideaKey)
        let suggestedSectionIndex = sections.firstIndex(of: .suggested) ?? 0
        if let cell = collectionView.cellForItem(
            at: IndexPath(row: index, section: suggestedSectionIndex)
        ) as? IdeaCells {
            cell.configure(idea: ideas[index])
        }
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    @IBAction func viewLikedTap(_: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "ViewScripts", bundle: nil)
        guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController else { return }
        guard let destinationVC = navVC.topViewController as? ViewScriptsViewController else { return }
        destinationVC.pageTitle = "Liked Ideas"
        navigationController?.pushViewController(destinationVC, animated: true)
    }

    func syncLikedState(_ ideas: [Idea]) -> [Idea] {
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

    @objc private func fetchProfileButtonData() {
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 20
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.isUserInteractionEnabled = true

        Task {
            do {
                let (profile, image) = try await SessionManager.shared.getProfileAndAvatar()
                await MainActor.run {
                    if let image = image {
                        self.profileImageView.image = image
                        self.profileImageView.backgroundColor = .clear
                    } else {
                        self.profileImageView.image = self.makeInitialAvatar(for: profile.fullName)
                        self.profileImageView.backgroundColor = UIColor.accent
                    }
                }
            } catch {
                print("Failed to fetch profile:", error)
            }
        }
    }

    private func makeInitialAvatar(for fullName: String) -> UIImage {
        let initial = fullName.first.map { String($0).uppercased() } ?? "U"
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40))
        return renderer.image { _ in
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                .foregroundColor: UIColor.white
            ]
            let string = NSAttributedString(string: initial, attributes: attributes)
            let stringSize = string.size()
            let rect = CGRect(
                x: (40 - stringSize.width) / 2,
                y: (40 - stringSize.height) / 2,
                width: stringSize.width,
                height: stringSize.height
            )
            string.draw(in: rect)
        }
    }

    @IBAction func profileTapped(_: Any) {
        let storyboard = UIStoryboard(name: "ProfileNew", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC")
        navigationController?.pushViewController(destVC, animated: true)
    }
}

extension Notification.Name {
    static let didUpdateLikedStatus = Notification.Name("didUpdateLikedStatus")
}
