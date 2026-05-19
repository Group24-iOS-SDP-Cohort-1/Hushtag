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
        if !likedIdeas.isEmpty {
            list.append(.liked)
        }
        if !recentScripts.isEmpty {
            list.append(.recent)
        }
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
        // Fetch recent scripts
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

                let syncedLikedIdeas = fetchedLikedIdeas.compactMap { liked in
                    personalizedIdeas.first(where: { $0.ideaKey == liked.ideaKey })
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
                // Fetch conversations to get sorted scripted ideas
                let conversations = try await scriptsController.fetchConversations()

                // Extract scripts from conversations that have them
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

                // Take top 4 (already sorted by created_at in fetchConversations)
                let top4 = Array(allScripts.prefix(4))

                await MainActor.run {
                    print("🔄 Updating recentScripts")

                    self.recentScripts = top4

                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
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
        // Use existing HeaderView
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
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )

        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func handleLikeUpdate(_ notification: Notification) {
        guard let ideaKey = notification.object as? String,
              let index = ideas.firstIndex(where: { $0.ideaKey == ideaKey })
        else {
            return
        }

        ideas[index].liked = LikedIds.likedIdeaIds.contains(ideaKey)

        // Dynamic section adjustment
        let suggestedSectionIndex = sections.firstIndex(of: .suggested) ?? 0

        if let cell = collectionView.cellForItem(
            at: IndexPath(row: index, section: suggestedSectionIndex)
        ) as? IdeaCells {
            cell.configure(idea: ideas[index])
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func viewLikedTap(_: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "ViewScripts", bundle: nil)
        guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController else { return }
        guard let destinationVC = navVC.topViewController as? ViewScriptsViewController else { return }
        destinationVC.pageTitle = "Liked Ideas"
        navigationController?.pushViewController(destinationVC, animated: true)
    }

    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let sectionType = self.sections[sectionIndex]

            switch sectionType {
            case .search:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(1)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: itemSize,
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)

                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(370)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )

                section.boundarySupplementaryItems = [header]

                return section

            case .chatbot:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(116)
                )

                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: itemSize,
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 20,
                    leading: 0,
                    bottom: 20,
                    trailing: 0
                )
                return section

            case .liked:
                return self.horizontalScrollingSection()

            case .recent:
                return self.horizontalScrollingSection()

            case .suggested:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(116)
                )

                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: itemSize,
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 20,
                    leading: 0,
                    bottom: 20,
                    trailing: 0
                )

                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .estimated(50)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )

                section.boundarySupplementaryItems = [header]
                section.interGroupSpacing = 15

                return section
            }
        }
    }

    func horizontalScrollingSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.95),
            heightDimension: .fractionalHeight(1.0)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.65),
            heightDimension: .estimated(120)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(50)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [header]
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 20,
            leading: 0,
            bottom: 20,
            trailing: 0
        )

        return section
    }

    private func syncLikedState(_ ideas: [Idea]) -> [Idea] {
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
                        let initial = profile.fullName.first.map { String($0).uppercased() } ?? "U"

                        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40))
                        let img = renderer.image { _ in
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

                        self.profileImageView.image = img
                        self.profileImageView.backgroundColor = UIColor.accent
                    }
                }
            } catch {
                print("Failed to fetch profile:", error)
            }
        }
    }

    @IBAction func profileTapped(_: Any) {
        let storyboard = UIStoryboard(name: "ProfileNew", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC")
        navigationController?.pushViewController(destVC, animated: true)
    }
}

extension Ideate1: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in _: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = sections[section]

        switch sectionType {
        case .search:
            return 0
        case .chatbot:
            return 1
        case .liked:
            return likedIdeas.count
        case .recent:
            return recentScripts.count
        case .suggested:
            return ideas.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let sectionType = sections[indexPath.section]

        switch sectionType {
        case .chatbot:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatbotAssistant", for: indexPath)
            cell.applyLiquidGlassEffect()
            return cell

        case .liked:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "likedCellsNew",
                for: indexPath
            ) as? LikedCellsNew else {
                return UICollectionViewCell()
            }

            let idea: Idea
            idea = likedIdeas[indexPath.row]
            cell.configureCell(idea: idea)
            cell.delegate = self
            cell.likeButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)

            return cell

        case .recent:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "scriptCellIdeate",
                for: indexPath
            ) as? ScriptIdeateCell else {
                return UICollectionViewCell()
            }

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

        case .suggested:
            guard let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: "ideaCell", for: indexPath) as? IdeaCells
            else {
                return UICollectionViewCell()
            }
            cell.configure(idea: ideas[indexPath.row])
            cell.delegate = self
            return cell

        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let sectionType = sections[indexPath.section]

        switch sectionType {
        case .search:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "IdeaSearch",
                for: indexPath
            ) as? IdeaSearch else {
                return UICollectionReusableView()
            }
            header.configure(state: .ideateMain)
            header.delegate = self
            return header

        case .liked:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "headerCell",
                for: indexPath
            ) as? HeaderView else {
                return UICollectionReusableView()
            }

            header.configureHeader(text: "Saved Ideas")
            header.showChevron(true)

            header.didTapChevron = { [weak self] in
                let storyboard = UIStoryboard(name: "ViewScripts", bundle: nil)
                guard let navVC = storyboard.instantiateInitialViewController()
                    as? UINavigationController else { return }
                guard let destinationVC = navVC.topViewController as? ViewScriptsViewController else { return }
                destinationVC.pageTitle = "Liked Ideas"
                self?.navigationController?.pushViewController(destinationVC, animated: true)
            }

            return header

        case .recent:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "headerCell",
                for: indexPath
            ) as? HeaderView else {
                return UICollectionReusableView()
            }
            header.configureHeader(text: "Generated Posts")
            header.showChevron(true)

            header.didTapChevron = { [weak self] in
                let storyboard = UIStoryboard(name: "ViewScripts", bundle: nil)
                guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController
                else { return }
                guard let destinationVC = navVC.topViewController as? ViewScriptsViewController else { return }
                destinationVC.pageTitle = "Your Scripts"
                self?.navigationController?.pushViewController(destinationVC, animated: true)
            }
            return header

        case .suggested:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "headerCell",
                for: indexPath
            ) as? HeaderView else {
                return UICollectionReusableView()
            }
            header.configureHeader(text: "Suggested For You")
            header.showChevron(false)
            header.isHidden = isSearching
            return header

        default:
            return UICollectionReusableView()
        }
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionType = sections[indexPath.section]

        switch sectionType {
        case .chatbot:
            let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)
            guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController,
                  let chatbotVC = navVC.topViewController as? Chatbot else { return }
            navigationController?.pushViewController(chatbotVC, animated: true)

        case .liked:
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

        case .recent:
            let script = recentScripts[indexPath.row]

            if let ideaId = script.ideaId {
                let storyboard = UIStoryboard(name: "ViewIdea", bundle: nil)
                if let destinationVC = storyboard.instantiateViewController(withIdentifier: "IdeaVC") as? ViewIdea {
                    destinationVC.ideaId = ideaId
                    navigationController?.pushViewController(destinationVC, animated: true)
                }
            } else {
                let storyboard = UIStoryboard(name: "Ideate", bundle: nil)
                if let destinationVC =
                    storyboard.instantiateViewController(withIdentifier: "scriptedIdea")
                        as? ScriptedIdeas {
                    destinationVC.idea = script
                    navigationController?.pushViewController(destinationVC, animated: true)
                }
            }

        case .suggested:
            let idea = ideas[indexPath.row]
            let storyboard = UIStoryboard(name: "ViewIdea", bundle: nil)
            guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController else { return }
            guard let destinationVC = navVC.topViewController as? ViewIdea else { return }
            destinationVC.idea = idea
            navigationController?.pushViewController(destinationVC, animated: true)

        default:
            break
        }
    }
}

extension Notification.Name {
    static let didUpdateLikedStatus = Notification.Name("didUpdateLikedStatus")
}

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
        )
            as? AfterSearchIdeasViewController {
            searchVC.keyword = keyword
            navigationController?.pushViewController(searchVC, animated: true)
        }
    }
}
