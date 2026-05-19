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
        guard let _ = idea else {
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

    @objc private func handleDealTagChanged() {
        fetchDealsData()
    }

    @objc private func handleScriptDeletedRemotely(_ notification: Notification) {
        guard let deletedID = notification.userInfo?["deletedID"] as? UUID,
              deletedID == idea?.id else { return }

        // This instance is showing the deleted idea — navigate away
        if navigationController?.presentingViewController != nil {
            navigationController?.dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    private func fetchDealsData() {
        guard let ideaId = idea?.id else { return }

        Task {
            do {
                let fetchedDeals = try await dealsController.fetchDeals()
                let mappings = try await brandDealIdeasController.fetchDealsForScript(scriptedIdeaId: ideaId)

                DispatchQueue.main.async {
                    self.allDeals = fetchedDeals
                    let ids = mappings.map { $0.dealId }
                    self.taggedDealIds = Set(ids)
                    self.orderedTaggedDealIds = ids
                    self.ideaView.reloadData() // Reload to update button menu if needed
                }
            } catch {
                print("Failed to fetch deals data: \(error)")
            }
        }
    }

    @objc func buttonTapped(_ sender: UIButton) {
        let section = sections[sender.tag]

        switch section {
        case .description:
            isDescriptionExpanded.toggle()

        case .script:
            isScriptExpanded.toggle()

        default:
            return
        }

        ideaView.reloadSections(IndexSet(integer: sender.tag))
    }

    func registerCell() {
        ideaView.register(
            UINib(nibName: "HeaderView",
                  bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "headerCell"
        )
    }

    private func setupMenu() {
        if isEditingMode {
            let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveEdits))
            navigationItem.rightBarButtonItem = saveButton
            return
        }

        let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [weak self] _ in
            self?.toggleEditMode()
        }
        let deleteAction = UIAction(title: "Delete Script", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
            self?.confirmDelete()
        }

        let menuChildren = isModal ? [deleteAction] : [editAction, deleteAction]

        let menu = UIMenu(title: "", children: menuChildren)

        if navigationItem.rightBarButtonItem != optionsBarButton {
            navigationItem.rightBarButtonItem = optionsBarButton
        }
        optionsBarButton.menu = menu
    }

    @objc private func toggleEditMode() {
        isEditingMode = true
        setupMenu()
        isDescriptionExpanded = true
        isScriptExpanded = true
        ideaView.reloadData()
    }

    @objc private func saveEdits() {
        guard let id = idea?.id else { return }

        isEditingMode = false
        setupMenu()
        ideaView.reloadData()

        Task {
            do {
                try await dbController.updateScript(
                    id: id,
                    title: idea?.title,
                    description: idea?.description,
                    script: idea?.script
                )
            } catch {
                print("Error saving edits: \(error)")
            }
        }
    }

    @IBAction func draftClick(_: Any) {
        navigateToChat()
    }

    private func confirmDelete() {
        let alert = UIAlertController(title: "Delete Script", message: "Are you sure? This cannot be undone.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.performDelete()
        }))

        present(alert, animated: true)
    }

    private func performDelete() {
        guard let id = idea?.id else { return }

        Task {
            do {
                try await dbController.deleteScript(id: id)

                NotificationCenter.default.post(
                    name: .scriptDeleted,
                    object: nil,
                    userInfo: ["deletedID": id]
                )

                DispatchQueue.main.async {
                    if self.navigationController?.presentingViewController != nil {
                        self.navigationController?.dismiss(animated: true)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }

            } catch {
                print("Error deleting script: \(error)")
            }
        }
    }

    private func navigateToChat() {
        guard let idea = idea else { return }

        let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)

        guard let chatVC = storyboard.instantiateViewController(
            withIdentifier: "Chatbot"
        ) as? Chatbot else { return }

        // This is the important line
        chatVC.conversationID = idea.chatId

        navigationController?.pushViewController(chatVC, animated: true)
    }

    @IBAction func schedule(_: Any) {
        let storyboard = UIStoryboard(name: "AddPostViewController", bundle: nil)
        let modalVC = storyboard.instantiateViewController(withIdentifier: "AddPostNavVC")
        modalVC.modalPresentationStyle = .pageSheet
        modalVC.modalTransitionStyle = .coverVertical
        present(modalVC, animated: true)
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
}

extension ScriptedIdeas: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = sections[indexPath.section]

        switch section {
        case .title:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "title",
                for: indexPath
            ) as! ViewScriptsCell

            cell.configureTitle(with: idea?.title ?? "")
            cell.setEditingMode(isEditingMode, isTitle: true)
            cell.textChangedHandler = { [weak self] newText in
                self?.idea?.title = newText
            }
            return cell

        case .buttons:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "buttons",
                for: indexPath
            ) as! ViewScriptsCell

            setupTagDealMenu(for: cell)

            return cell

        default:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "content",
                for: indexPath
            ) as! ViewScriptsCell

            cell.readMoreButton.tag = indexPath.section
            cell.readMoreButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

            switch section {
            case .description:
                cell.configure(with: idea?.description ?? "")

                if isDescriptionExpanded {
                    cell.content.numberOfLines = 0
                    cell.readMoreButton.setTitle("Show Less", for: .normal)
                } else {
                    cell.content.numberOfLines = 8
                    cell.readMoreButton.setTitle("Read More", for: .normal)
                }

                cell.setEditingMode(isEditingMode, isTitle: false)
                cell.textChangedHandler = { [weak self] newText in
                    self?.idea?.description = newText
                }

            case .script:
                cell.configure(with: idea?.script ?? "")

                if isScriptExpanded {
                    cell.content.numberOfLines = 0
                    cell.readMoreButton.setTitle("Show Less", for: .normal)
                } else {
                    cell.content.numberOfLines = 8
                    cell.readMoreButton.setTitle("Read More", for: .normal)
                }

                cell.setEditingMode(isEditingMode, isTitle: false)
                cell.textChangedHandler = { [weak self] newText in
                    self?.idea?.script = newText
                }

            default:
                break
            }

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == "header" else { return UICollectionReusableView() }

        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: "header",
            withReuseIdentifier: "headerCell",
            for: indexPath
        ) as! HeaderView

        let section = sections[indexPath.section]

        switch section {
        case .description:
            headerView.configureHeader(text: "Description")
        case .script:
            headerView.configureHeader(text: "Script")
        default:
            headerView.configureHeader(text: "")
        }

        return headerView
    }

    private func setupTagDealMenu(for cell: ViewScriptsCell) {
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
                            CapsuleNotification.show(message: "Unmarked from \(deal.name)", iconName: "bookmark.slash.fill")
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
                    let alert = UIAlertController(title: "Error", message: "Failed to update deal tag. Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
