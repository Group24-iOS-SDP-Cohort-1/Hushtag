import UIKit

protocol DealsInfoDelegate: AnyObject {
    func dealsInfo(_ controller: DealsInfo, didUpdateDeal deal: Deal, at index: Int)
}

final class DealsInfo: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var deals: Deal!
    var dealIndex: Int = -1
    var selectedIdea: Idea?
    weak var delegate: DealsInfoDelegate?

    private let cardBackgroundKind = "card-background"
}

extension DealsInfo {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = deals.name
        view.backgroundColor = .black

        configureCollectionView()
        configureLayout()
    }
}

extension DealsInfo {

    enum Section: Int, CaseIterable {
        case details
        case deliverables
        case selectedIdea
        case notes
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
            NotesCell.self,
            forCellWithReuseIdentifier: "NotesCell"
        )

        collectionView.register(
            UINib(nibName: "HeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "headerCell"
        )
    }
}

extension DealsInfo {

    
    //layout for the sections
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

    //layout for the note
    private func makePlainNotesSection() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(44)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: itemSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 16)

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(36)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.contentInsets = .init(top: 0, leading: 0, bottom: 12, trailing: 0)
        section.boundarySupplementaryItems = [header]

        return section
    }
    

    // setting the height for each section
    private func configureLayout() {

        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in

            let section = Section(rawValue: sectionIndex)!

            if section == .details {
                return self.makeCardSection(estimatedItemHeight: 56)
            }
            else if section == .deliverables {
                return self.makeCardSection(estimatedItemHeight: 64)
            }
            else if section == .selectedIdea {
                return self.makeCardSection(estimatedItemHeight: 150)
            }
            else {
                return self.makePlainNotesSection()
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
        Section.allCases.count
    }

    
    // no of items in the per section
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        let type = Section(rawValue: section)!

        switch type {
        case .details: return 3
        case .deliverables: return deals.deliverable.count
        case .selectedIdea: return selectedIdea == nil ? 0 : 1
        case .notes: return deals.description.isEmpty == false ? 1 : 0
        }
    }
    
    
    // configuring the cell for particular index
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let type = Section(rawValue: indexPath.section)!

        switch type {

        case .details:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DetailsCell",
                for: indexPath
            ) as! DetailsCell

            let isLast = indexPath.item == 2

            if indexPath.item == 0 {
                cell.configure(iconName: "creditcard", text: "Rs \(deals.payment)", isLast: isLast)
            } else if indexPath.item == 1 {
                cell.configure(iconName: "envelope", text: deals.email, isLast: isLast)
            } else {
                cell.configure(iconName: "phone", text: deals.phone, isLast: isLast)
            }
            return cell

        case .deliverables:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DeliverableCell.reuseId,
                for: indexPath
            ) as! DeliverableCell

            let isLast = indexPath.item == deals.deliverable.count - 1
            cell.configure(with: deals.deliverable[indexPath.item], isLast: isLast)
            return cell

        case .selectedIdea:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "selectedIdeaCell",
                for: indexPath
            ) as! ScriptsCell1
            cell.configureCell(idea: selectedIdea!)
            return cell

        case .notes:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "NotesCell",
                for: indexPath
            ) as! NotesCell
            cell.label.text = deals.description
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

        let type = Section(rawValue: indexPath.section)!

        switch type {
        case .details: header.configureHeader(text: "Details")
        case .deliverables: header.configureHeader(text: "Deliverables")
        case .selectedIdea: header.configureHeader(text: "Selected Idea")
        case .notes: header.configureHeader(text: "Notes")
        }

        return header
    }
}

extension DealsInfo: UICollectionViewDelegate {

    //all the cell are clickable but we are allowing only deliverable section to be clickable
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        Section(rawValue: indexPath.section) == .deliverables
    }

    
    // function for toggle the deliverables
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        guard Section(rawValue: indexPath.section) == .deliverables else { return }

        deals.deliverable[indexPath.item].isCompleted.toggle()
        collectionView.reloadItems(at: [indexPath])

        if dealIndex >= 0 {
            delegate?.dealsInfo(self, didUpdateDeal: deals, at: dealIndex)
        }
    }
}
