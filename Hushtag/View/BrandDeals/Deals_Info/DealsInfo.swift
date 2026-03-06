import UIKit

protocol DealsInfoDelegate: AnyObject {
    func dealsInfo(_ controller: DealsInfo, didUpdateDeal deal: Deal, at index: Int)
    func dealsInfo(_ controller: DealsInfo, didDeleteDeal dealId: UUID)

}

final class DealsInfo: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var delete: UIBarButtonItem!

    var deals: Deal!
    var dealIndex: Int = -1
    var selectedIdea: ScriptedIdea?
    weak var delegate: DealsInfoDelegate?


    private let cardBackgroundKind = "card-background"

    @IBOutlet weak var completeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = deals.name
        view.backgroundColor = .black
        
        configureCollectionView()
        configureLayout()
        
        // Initial setup
        completeButton.layer.cornerRadius = 12
        updateButtonState()
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
        //completeButton.backgroundColor = color
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
                print("❌ Failed to update deal status:", error)
                // Revert UI on failure
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
                    // notify list screen
                    self.delegate?.dealsInfo(self, didDeleteDeal: dealId)

                    // go back to list
                    self.navigationController?.popViewController(animated: true)
                }

            } catch {
                print("❌ Delete failed:", error)
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

        if selectedIdea != nil {
            result.append(.selectedIdea)
        }


        return result
    }
}

extension DealsInfo {

    enum Section {
        case details
        case deliverables
        case selectedIdea

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
}

extension DealsInfo {

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


    

    // setting the height for each section
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
                return self.makeCardSection(estimatedItemHeight: 150)
            }
        }

        layout.register(
            CardBackgroundView.self,
            forDecorationViewOfKind: cardBackgroundKind
        )

        collectionView.collectionViewLayout = layout
    }
}


extension DealsInfo: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    
    // no of items in the per section
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        let type = sections[section]

        switch type {
        case .details: return 4
        case .deliverables: return deals.deliverables.count
        case .selectedIdea: return selectedIdea == nil ? 0 : 1

        }
    }
    
    
    // configuring the cell for particular index
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

                // 1. Toggle locally
                self.deals.deliverables[indexPath.item].isCompleted.toggle()

                let deliverable = self.deals.deliverables[indexPath.item]


                cell.updateStatus(isCompleted: deliverable.isCompleted)


                _Concurrency.Task {
                    do {
                        try await DealsController().updateDeliverableStatus(
                            deliverableId: deliverable.id,
                            isCompleted: deliverable.isCompleted
                        )
                        
                        // Check if the entire deal's completion status has changed based on deliverables
                        let currentDealIsCompleted = self.deals.isCompleted
                        try await DealsController().updateDealStatus(
                            dealId: self.deals.id,
                            isCompleted: currentDealIsCompleted
                        )

                        // notify parent
                        if self.dealIndex >= 0 {
                            self.delegate?.dealsInfo(self, didUpdateDeal: self.deals, at: self.dealIndex)
                        }

                    } catch {
                        print("❌ Deliverable/Deal update failed:", error)
                    }
                }
            }


            return cell


        case .selectedIdea:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "selectedIdeaCell",
                for: indexPath
            ) as! ScriptsCell1
            guard let selectedIdea = self.selectedIdea else { return UICollectionViewCell() }
            cell.configureCell(with : selectedIdea)
            return cell


        }
    }

    
    // setting the header for each section
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
        case .selectedIdea: header.configureHeader(text: "Selected Idea")

        }

        return header
    }
}

extension DealsInfo: UICollectionViewDelegate {

    //all the cell are clickable but we are allowing only deliverable section to be clickable
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        sections[indexPath.section] == .deliverables
    }
    
    // function for toggle the deliverables
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
