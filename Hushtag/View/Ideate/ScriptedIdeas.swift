import UIKit

extension Notification.Name {
    static let scriptDeleted = Notification.Name("scriptDeleted")
}

class ScriptedIdeas: UIViewController {
    
    @IBOutlet weak var optionsBarButton: UIBarButtonItem!
    @IBOutlet weak var ideaView: UICollectionView!
    var isDescriptionExpanded = false
    var isScriptExpanded = false
    
    private let dbController = ScriptedIdeasController()
    private let dealsController = DealsController()
    private let brandDealIdeasController = BrandDealIdeasController()
    
    var idea: ScriptedIdea?
    var allDeals: [Deal] = []
    var taggedDealIds: Set<UUID> = []
    
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
    }
    
    private func fetchDealsData() {
        guard let ideaId = idea?.id else { return }
        
        Task {
            do {
                let fetchedDeals = try await dealsController.fetchDeals()
                let mappings = try await brandDealIdeasController.fetchDealsForScript(scriptedIdeaId: ideaId)
                
                DispatchQueue.main.async {
                    self.allDeals = fetchedDeals
                    self.taggedDealIds = Set(mappings.map { $0.deal_id })
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
            withReuseIdentifier: "headerCell")
    }
    
    private func setupMenu() {
        // Option 1: View Chat History
        let chatAction = UIAction(title: "View Chat History", image: UIImage(systemName: "bubble.left.and.bubble.right.fill")) { [weak self] _ in
            self?.navigateToChat()
        }
        
        // Option 2: Delete Script (Destructive)
        let deleteAction = UIAction(title: "Delete Script", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
            self?.confirmDelete()
        }
        
        // Attach menu to the bar button
        let menu = UIMenu(title: "", children: [chatAction, deleteAction])
        optionsBarButton.menu = menu
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
                    self.navigationController?.popViewController(animated: true)
                }
                
            } catch {
                print("Error deleting script: \(error)")
            }
        }
    }
    
    private func navigateToChat() {
        guard let idea = self.idea else { return }
        
        let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)
        
        guard let chatVC = storyboard.instantiateViewController(
            withIdentifier: "Chatbot"
        ) as? Chatbot else { return }
        
        // This is the important line
        chatVC.conversationID = idea.chat_id
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @IBAction func schedule(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AddPostViewController", bundle: nil)
        let modalVC = storyboard.instantiateViewController(withIdentifier: "AddPostNavVC")
        modalVC.modalPresentationStyle = .pageSheet
        modalVC.modalTransitionStyle = .coverVertical
        present(modalVC, animated: true)
    }
    
    func generateLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, env in
            
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
            
            if sectionIndex == 1 || sectionIndex == 2 {
                section.boundarySupplementaryItems = [headerItem]
            }
            return section
        }
        return layout
    }
}

extension ScriptedIdeas: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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

            case .script:
                cell.configure(with: idea?.script ?? "")
                
                if isScriptExpanded {
                    cell.content.numberOfLines = 0
                    cell.readMoreButton.setTitle("Show Less", for: .normal)
                } else {
                    cell.content.numberOfLines = 8
                    cell.readMoreButton.setTitle("Read More", for: .normal)
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
        let actions = allDeals.map { deal in
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
        
        let menu = UIMenu(title: "Select Deal", children: actions)
        cell.tagDealButton.menu = menu
        cell.tagDealButton.showsMenuAsPrimaryAction = true
    }
    
    private func handleTagDealToggled(deal: Deal, isCurrentlyTagged: Bool) {
        guard let ideaId = idea?.id else { return }
        
        Task {
            do {
                if isCurrentlyTagged {
                    try await brandDealIdeasController.untagDealFromScript(dealId: deal.id, scriptedIdeaId: ideaId)
                    
                    DispatchQueue.main.async {
                        self.taggedDealIds.remove(deal.id)
                        self.ideaView.reloadSections(IndexSet(integer: self.sections.firstIndex(of: .buttons) ?? 0))
                        
                        let alert = UIAlertController(title: "Unmarked", message: "Unmarked from \(deal.name)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                } else {
                    try await brandDealIdeasController.tagDealToScript(dealId: deal.id, scriptedIdeaId: ideaId)
                    
                    DispatchQueue.main.async {
                        self.taggedDealIds.insert(deal.id)
                        self.ideaView.reloadSections(IndexSet(integer: self.sections.firstIndex(of: .buttons) ?? 0))
                        
                        let alert = UIAlertController(title: "Marked", message: "Marked to \(deal.name)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
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
