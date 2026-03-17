import UIKit

protocol DealsInfoDelegate: AnyObject {
    func dealsInfo(_ controller: DealsInfo, didUpdateDeal deal: Deal, at index: Int)
    func dealsInfo(_ controller: DealsInfo, didDeleteDeal dealId: UUID)
    
}

class DealsInfo: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var delete: UIBarButtonItem!
    
    var deals: Deal!
    var dealIndex: Int = -1
    var selectedIdeas: [ScriptedIdea] = []
    weak var delegate: DealsInfoDelegate?
    
    
    private let cardBackgroundKind = "card-background"
    
    private let brandDealIdeasController = BrandDealIdeasController()
    private let scriptedIdeasController = ScriptedIdeasController()
    
    @IBOutlet weak var completeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = deals.name
        view.backgroundColor = .black
        
        configureCollectionView()
        configureLayout()
        
        
        completeButton.layer.cornerRadius = 12
        updateButtonState()
        
        fetchLinkedIdeas()
    }
    
    private func fetchLinkedIdeas() {
            // We use Task to run the async network calls
            Task {
                do {
                    // Step A: Get the mappings for this specific deal
                    let mappings = try await brandDealIdeasController.fetchScriptsForDeal(dealId: deals.id)
                    
                    // Extract just the UUIDs from the mappings
                    let ideaIds = mappings.map { $0.scripted_idea_id }
                    
                    // If there are no linked ideas, just reload the empty section and exit
                    guard !ideaIds.isEmpty else {
                        self.selectedIdeas = []
                        await MainActor.run { self.collectionView.reloadData() }
                        return
                    }
                    
                    // Step B: Fetch the actual ScriptedIdea content using the extracted IDs
                    let fetchedIdeas = try await scriptedIdeasController.fetchScripts(byIds: ideaIds)
                    
                    // Step C: Update the UI on the main thread
                    await MainActor.run {
                        self.selectedIdeas = fetchedIdeas
                        self.collectionView.reloadData()
                    }
                    
                } catch {
                    print("❌ Failed to fetch linked ideas:", error)
                    // Optional: Handle the error gracefully in your UI here
                }
            }
        }
    
    private func updateButtonState() {
        if !deals.deliverables.isEmpty {
            completeButton.isHidden = true
            return
        }
        
        completeButton.isHidden = false
        
        let isCompleted = deals.isManuallyCompleted
        let title = isCompleted ? "Marked" : "Mark as Completed"
        
        
        completeButton.setTitle(title, for: .normal)
    }
    
    @IBAction func toggleCompletionStatus(_ sender: Any) {
        let newStatus = !deals.isManuallyCompleted
        deals.isManuallyCompleted = newStatus
        updateButtonState()
        
        _Concurrency.Task {
            do {
                try await DealsController().updateDealStatus(dealId: deals.id, isCompleted: newStatus)
                
                await MainActor.run {
                    self.delegate?.dealsInfo(self, didUpdateDeal: self.deals, at: self.dealIndex)
                }
            } catch {
                //print("❌ Failed to update deal status:", error)
                deals.isManuallyCompleted = !newStatus
                updateButtonState()
            }
        }
    }
    
    @IBAction func editModal(_ sender: Any) {
        let storyboard = UIStoryboard(name: "BrandDeals", bundle: nil)
        
        let vc = storyboard.instantiateViewController(
            withIdentifier: "AddDealsViewController"
        ) as! AddDealsViewController
        
        vc.editingDeal = deals
        vc.editingIndex = dealIndex
        
        vc.title = deals.name
        
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        
        present(nav, animated: true)
    }
    
    
    @IBAction func deleteDeal(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Delete Deal",
            message: "This deal will be permanently deleted.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteDeal()
        })
        
        present(alert, animated: true)
    }
    
    private func deleteDeal() {
        let dealId = deals.id
        
        _Concurrency.Task {
            do {
                try await DealsController().deleteDeal(dealId)
                
                await MainActor.run {
                    
                    self.delegate?.dealsInfo(self, didDeleteDeal: dealId)
                    self.navigationController?.popViewController(animated: true)
                }
                
            } catch {
                //print("❌ Delete failed:", error)
            }
        }
    }
}



extension DealsInfo {
    
    
    private var sections: [Section] {
        var result: [Section] = [.details]
        
        if !deals.deliverables.isEmpty {
            result.append(.deliverables)
        }
        
        // Check the array instead of a single optional
        if !selectedIdeas.isEmpty {
            result.append(.selectedIdeas)
        }
        
        return result
    }
}

extension DealsInfo {
    
    enum Section {
        case details
        case deliverables
        case selectedIdeas
        
    }
}


extension DealsInfo {
    
    private func configureCollectionView() {
        
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            UINib(nibName: "DetailsCell", bundle: nil),
            forCellWithReuseIdentifier: "DetailsCell"
        )
        
        collectionView.register(
            UINib(nibName: "DeliverableCell", bundle: nil),
            forCellWithReuseIdentifier: DeliverableCell.reuseId
        )
        
        collectionView.register(
            UINib(nibName: "ScriptsCell1", bundle: nil),
            forCellWithReuseIdentifier: "selectedIdeaCell"
        )
        
        
        collectionView.register(
            UINib(nibName: "HeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "headerCell"
        )
    }
    
    private func configureLayout() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            
            let section = self.sections[sectionIndex]
            
            if section == .details {
                return self.makeCardSection(estimatedItemHeight: 56)
            }
            else if section == .deliverables {
                return self.makeCardSection(estimatedItemHeight: 64)
            }
            else {
                // Apply the modification below
                return self.makeOrthogonalSection(estimatedItemHeight: 150)
            }
        }
        
        layout.register(
            CardBackgroundView.self,
            forDecorationViewOfKind: cardBackgroundKind
        )
        
        collectionView.collectionViewLayout = layout
    }
    
    // Kept for Details and Deliverables sections
    private func makeCardSection(estimatedItemHeight: CGFloat) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(estimatedItemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(36)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.contentInsets = .init(top: 0, leading: 0, bottom: 4, trailing: 0)
        section.boundarySupplementaryItems = [header]
        
        let background = NSCollectionLayoutDecorationItem.background(
            elementKind: cardBackgroundKind
        )
        background.contentInsets = .init(top: 38, leading: 16, bottom: 16, trailing: 16)
        section.decorationItems = [background]
        
        return section
    }
    
    // UPDATED FUNCTION: Renamed and modified to remove background for ideas
    private func makeOrthogonalSection(estimatedItemHeight: CGFloat) -> NSCollectionLayoutSection {
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // Group is still 85% width so the next card "peeks" in from the right
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.85),
                heightDimension: .estimated(estimatedItemHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            
            // 1. Change behavior to groupPaging (aligns to leading edge instead of center)
            section.orthogonalScrollingBehavior = .groupPaging
            section.interGroupSpacing = 16
            
            // 2. Add back the leading margin (16) so it aligns with your headers/other cards
            section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(36)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            // Adjust header to 0 since the section now handles the 16pt left margin
            header.contentInsets = .init(top: 0, leading: 0, bottom: 4, trailing: 0)
            section.boundarySupplementaryItems = [header]
            
            return section
        }
}

extension DealsInfo: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        
        switch type {
        case .details: return 4
        case .deliverables: return deals.deliverables.count
        case .selectedIdeas: return selectedIdeas.count // Return the array count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let type = sections[indexPath.section]
        
        switch type {
            
        case .details:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DetailsCell",
                for: indexPath
            ) as! DetailsCell
            
            let isLast = indexPath.item == 3
            
            if indexPath.item == 0 {
                cell.configure(iconName: "calendar", text: deals.deadline.deadlineFormatted(), isLast: isLast)
            } else if indexPath.item == 1 {
                cell.configure(iconName: "creditcard", text: "Rs \(deals.payment)", isLast: isLast)
            } else if indexPath.item == 2 {
                cell.configure(iconName: "envelope", text: deals.email, isLast: isLast)
            } else {
                cell.configure(iconName: "phone", text: "\(deals.mobileNumber)", isLast: isLast)
            }
            return cell
            
        case .deliverables:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DeliverableCell.reuseId,
                for: indexPath
            ) as! DeliverableCell
            
            let isLast = indexPath.item == deals.deliverables.count - 1
            let deliverable = deals.deliverables[indexPath.item]
            
            cell.configure(with: deliverable, isLast: isLast)
            
            cell.onToggleStatus = { [weak self] in
                guard let self = self else { return }
                
                
                self.deals.deliverables[indexPath.item].isCompleted.toggle()
                let deliverable = self.deals.deliverables[indexPath.item]
                cell.updateStatus(isCompleted: deliverable.isCompleted)
                
                
                _Concurrency.Task {
                    do {
                        try await DealsController().updateDeliverableStatus(
                            deliverableId: deliverable.id,
                            isCompleted: deliverable.isCompleted
                        )
                        
                        let currentDealIsCompleted = self.deals.isCompleted
                        try await DealsController().updateDealStatus(
                            dealId: self.deals.id,
                            isCompleted: currentDealIsCompleted
                        )
                        
                        if self.dealIndex >= 0 {
                            self.delegate?.dealsInfo(self, didUpdateDeal: self.deals, at: self.dealIndex)
                        }
                        
                    } catch {
                        //print("❌ Deliverable/Deal update failed:", error)
                    }
                }
            }
            
            
            return cell
            
            
        case .selectedIdeas:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "selectedIdeaCell",
                    for: indexPath
                ) as! ScriptsCell1
                
                // Grab the idea for this specific index
                let idea = selectedIdeas[indexPath.item]
                cell.configureCell(with: idea)
                return cell
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "headerCell",
            for: indexPath
        ) as! HeaderView
        
        let type = sections[indexPath.section]
        
        switch type {
        case .details: header.configureHeader(text: "Details")
        case .deliverables: header.configureHeader(text: "Deliverables")
        case .selectedIdeas: header.configureHeader(text: "Selected Ideas")
            
        }
        
        return header
    }
}

extension DealsInfo: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        sections[indexPath.section] == .deliverables
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        guard sections[indexPath.section] == .deliverables else { return }
        
        deals.deliverables[indexPath.item].isCompleted.toggle()
        collectionView.reloadItems(at: [indexPath])
        
        if dealIndex >= 0 {
            delegate?.dealsInfo(self, didUpdateDeal: deals, at: dealIndex)
        }
        
    }
}

extension DealsInfo: AddDealsDelegate {
    
    func addDealsViewController(
        _ controller: AddDealsViewController,
        didUpdateDeal deal: Deal,
        at index: Int
    ) {
        
        self.deals = deal
        self.title = deal.name
        self.updateButtonState()
        self.collectionView.reloadData()
        
        
        if dealIndex >= 0 {
            delegate?.dealsInfo(self, didUpdateDeal: deal, at: -1)
            
        }
        
        dismiss(animated: true)
    }
    
    func addDealsViewController(
        _ controller: AddDealsViewController,
        didCreateDeal deal: Deal
    ) {}
}
