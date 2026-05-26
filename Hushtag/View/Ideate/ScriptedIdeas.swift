import UIKit

extension Notification.Name {
    static let scriptDeleted = Notification.Name("scriptDeleted")
    static let dealTagChanged = Notification.Name("dealTagChanged")
}

class ScriptedIdeas: UIViewController {
    @IBOutlet var optionsBarButton: UIBarButtonItem!
    @IBOutlet var ideaView: UICollectionView!
    var isDescriptionExpanded = false
    var isScriptExpanded = false
    var isEditingMode = false

    private let dbController = ScriptedIdeasController()
    private let dealsController = DealsController()
    private let brandDealIdeasController = BrandDealIdeasController()

    var idea: ScriptedIdea?
    var allDeals: [Deal] = []
    var taggedDealIds: Set<UUID> = []
    var orderedTaggedDealIds: [UUID] = []

    /// Set to true when presented modally (e.g. from DealsInfo). Hides "View Chat History" from the menu.
    var isModal: Bool = false

    /// Called when a deal is untagged. If set, the modal is dismissed instead of showing an alert.
    var onDealUntagged: (() -> Void)?

    var sections: [ScriptSection] {
        var result: [ScriptSection] = []

        if let title = idea?.title, !title.isEmpty {
            result.append(.title)
        }

        if let description = idea?.description, !description.isEmpty {
            result.append(.description)
        }

        if let script = idea?.script, !script.isEmpty {
            result.append(.script)
        }

        result.append(.buttons)

        return result
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ideaView.reloadData()
        setupMenu()
        registerCell()

        ideaView.delegate = self
        ideaView.dataSource = self
        ideaView.setCollectionViewLayout(generateLayout(), animated: true)
        guard idea != nil else {
            print("No idea received.")
            return
        }

        fetchDealsData()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDealTagChanged),
            name: .dealTagChanged,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScriptDeletedRemotely(_:)),
            name: .scriptDeleted,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshIdeaData()
    }

    func refreshIdeaData() {
        guard let ideaId = idea?.id else { return }

        Task {
            do {
                let updatedIdea = try await ScriptedIdeasController().fetchScriptById(id: ideaId)

                DispatchQueue.main.async {
                    self.idea = updatedIdea
                    self.ideaView.reloadData()
                }
            } catch {
                print("❌ Failed to refresh idea:", error)
            }
        }
    }

    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(50)
            )

            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: "header",
                alignment: .top
            )

            // self-sizing item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(100)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            // self-sizing group
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(100)
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 20,
                bottom: 20,
                trailing: 20
            )

            let currentSection = self.sections[sectionIndex]

            if currentSection == .description || currentSection == .script {
                section.boundarySupplementaryItems = [headerItem]
            }
            return section
        }
    }

    func setupTagDealMenu(for cell: ViewScriptsCell) {
        let actions: [UIMenuElement]

        if allDeals.isEmpty {
            let noDealsAction = UIAction(title: "No Deals Available", attributes: .disabled) { _ in }
            actions = [noDealsAction]
        } else {
            actions = allDeals.map { deal in
                let isTagged = taggedDealIds.contains(deal.id)
                let actionText = deal.name

                return UIAction(
                    title: actionText,
                    state: isTagged ? .on : .off,
                    handler: { [weak self] _ in
                        self?.handleTagDealToggled(deal: deal, isCurrentlyTagged: isTagged)
                    }
                )
            }
        }

        let menu = UIMenu(title: "Select Deal", children: actions)
        cell.tagDealButton.menu = menu
        cell.tagDealButton.showsMenuAsPrimaryAction = true

        if let lastId = orderedTaggedDealIds.last, let deal = allDeals.first(where: { $0.id == lastId }) {
            cell.tagDealButton.setTitle(deal.name, for: .normal)
        } else {
            cell.tagDealButton.setTitle("Tag Deal", for: .normal)
        }
    }

    private func handleTagDealToggled(deal: Deal, isCurrentlyTagged: Bool) {
        guard let ideaId = idea?.id else { return }

        Task {
            do {
                if isCurrentlyTagged {
                    try await brandDealIdeasController.untagDealFromScript(dealId: deal.id, scriptedIdeaId: ideaId)

                    DispatchQueue.main.async {
                        self.taggedDealIds.remove(deal.id)
                        self.orderedTaggedDealIds.removeAll { $0 == deal.id }
                        self.ideaView.reloadSections(IndexSet(integer: self.sections.firstIndex(of: .buttons) ?? 0))
                        NotificationCenter.default.post(name: .dealTagChanged, object: nil)

                        if let onUntagged = self.onDealUntagged {
                            self.dismiss(animated: true, completion: onUntagged)
                        } else {
                            CapsuleNotification.show(
                                message: "Unmarked from \(deal.name)",
                                iconName: "bookmark.slash.fill"
                            )
                        }
                    }
                } else {
                    try await brandDealIdeasController.tagDealToScript(dealId: deal.id, scriptedIdeaId: ideaId)

                    DispatchQueue.main.async {
                        self.taggedDealIds.insert(deal.id)
                        self.orderedTaggedDealIds.append(deal.id)
                        self.ideaView.reloadSections(IndexSet(integer: self.sections.firstIndex(of: .buttons) ?? 0))
                        NotificationCenter.default.post(name: .dealTagChanged, object: nil)

                        CapsuleNotification.show(message: "Marked to \(deal.name)", iconName: "bookmark.fill")
                    }
                }
            } catch {
                print("Error toggling tag deal status: \(error)")
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to update deal tag. Please try again.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    func registerCell() {
        ideaView.register(
            UINib(nibName: "HeaderView", bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "headerCell"
        )
    }
}
