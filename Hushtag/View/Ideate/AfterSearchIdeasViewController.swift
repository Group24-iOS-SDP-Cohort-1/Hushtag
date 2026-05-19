import UIKit

class AfterSearchIdeasViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!

    var keyword: String = ""
    var currentInputText: String = ""
    var ideas: [Idea] = []

    private let likedIdeasController = LikedIdeasController()

    enum SectionType {
        case search
        case suggested
    }

    let sections: [SectionType] = [.search, .suggested]

    override func viewDidLoad() {
        super.viewDidLoad()

        currentInputText = keyword

        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
        collectionView.dataSource = self
        collectionView.delegate = self

        registerCells()
        setupGlobalKeyboardDismiss()

        // Execute initial search
        if !keyword.isEmpty {
            performSearch(with: keyword)
        }
    }

    private func registerCells() {
        collectionView.register(UINib(nibName: "IdeaCells", bundle: nil), forCellWithReuseIdentifier: "ideaCell")
        collectionView.register(
            UINib(nibName: "IdeaSearch", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "IdeaSearch"
        )
        collectionView.register(
            UINib(nibName: "HeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "headerCell"
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

    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
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
                // Increase spacing below the search cell
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                return section

            case .suggested:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(116)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 10, leading: 0, bottom: 20, trailing: 0
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

    private func performSearch(with query: String) {
        OpaqueLoadingScreen.shared.show(message: "Searching ideas...")

        Task {
            do {
                let response = try await YouTubeService().search(query: query)
                let clusterIdeas = response.clusterIdeas

                let mappedIdeas: [Idea] = clusterIdeas.flatMap { cluster in
                    cluster.ideas.map { geminiIdea in
                        let key = makeIdeaKey(
                            title: geminiIdea.title,
                            description: geminiIdea.description,
                            format: geminiIdea.format,
                            hashtags: geminiIdea.hashtags
                        )
                        return Idea(
                            id: UUID(),
                            ideaKey: key,
                            title: geminiIdea.title,
                            description: geminiIdea.description,
                            format: geminiIdea.format,
                            hashtags: geminiIdea.hashtags,
                            noveltyScore: geminiIdea.noveltyScore,
                            videos: (cluster.videos).map { $0.toVideo() },
                            liked: LikedIds.likedIdeaIds.contains(key)
                        )
                    }
                }

                await MainActor.run {
                    self.ideas = mappedIdeas
                    self.collectionView.reloadData()
                    OpaqueLoadingScreen.shared.hide()
                }

            } catch {
                print("❌ ERROR:", error)
                await MainActor.run {
                    OpaqueLoadingScreen.shared.hide()
                }
            }
        }
    }
}

extension AfterSearchIdeasViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in _: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = sections[section]
        switch sectionType {
        case .search:
            return 0
        case .suggested:
            return ideas.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = sections[indexPath.section]
        switch sectionType {
        case .search:
            return UICollectionViewCell()
        case .suggested:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ideaCell", for: indexPath) as! IdeaCells
            cell.configure(idea: ideas[indexPath.row])
            cell.delegate = self
            return cell
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
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "IdeaSearch",
                for: indexPath
            ) as! IdeaSearch
            header.textLabel.text = currentInputText

            header.configure(state: .afterSearch(showCross: !currentInputText.isEmpty))

            header.delegate = self
            return header

        case .suggested:
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "headerCell",
                for: indexPath
            ) as! HeaderView
            header.configureHeader(text: "Search Results for \"\(keyword)\"")
            header.showChevron(false)
            return header
        }
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionType = sections[indexPath.section]
        switch sectionType {
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

extension AfterSearchIdeasViewController: IdeaSearchDelegate {
    func didTapSearch(with keyword: String) {
        currentInputText = keyword

        if keyword.isEmpty {
            // Keep the previous search results exactly as they are.
            // Reload collection view to force layout update and fix glitch when stack view is unhidden
            collectionView.reloadData()
            return
        }

        self.keyword = keyword
        collectionView.reloadData()
        performSearch(with: keyword)
    }
}

extension AfterSearchIdeasViewController: IdeaCellDelegate {
    func didToggleLikeFromFeed(for ideaKey: String) {
        guard let index = ideas.firstIndex(where: { $0.ideaKey == ideaKey }) else {
            return
        }

        let isCurrentlyLiked = LikedIds.likedIdeaIds.contains(ideaKey)
        let idea = ideas[index]

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
                    ideas[index].liked = !isCurrentlyLiked

                    if let smIndex = SessionManager.shared.personalizedIdeas.firstIndex(where: { $0.ideaKey == ideaKey }) {
                        SessionManager.shared.personalizedIdeas[smIndex].liked = !isCurrentlyLiked
                    }

                    NotificationCenter.default.post(name: .didUpdateLikedStatus, object: ideaKey)

                    guard let suggestedSectionIndex = sections.firstIndex(of: .suggested) else { return }

                    if let cell = collectionView.cellForItem(at: IndexPath(row: index, section: suggestedSectionIndex)) as? IdeaCells {
                        cell.configure(idea: ideas[index])
                    }
                }
            } catch {
                print("❌ Like toggle failed:", error)
            }
        }
    }
}
