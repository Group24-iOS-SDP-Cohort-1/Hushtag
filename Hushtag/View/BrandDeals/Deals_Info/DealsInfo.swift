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

    override func viewDidLoad() {
        super.viewDidLoad()

        title = deals.name
        view.backgroundColor = .black

        configureCollectionView()
        configureLayout()
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

//           if let sheet = nav.sheetPresentationController {
//               sheet.detents = [.medium(), .large()]
//               sheet.prefersGrabberVisible = true
//           }

           present(nav, animated: true)
    }
    
}

extension DealsInfo {

    
    private var sections: [Section] {
        var result: [Section] = [.details, .deliverables]

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
        case .details: return 3
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

            let isLast = indexPath.item == 2

            if indexPath.item == 0 {
                cell.configure(iconName: "creditcard", text: "Rs \(deals.payment)", isLast: isLast)
            } else if indexPath.item == 1 {
                cell.configure(iconName: "envelope", text: deals.email, isLast: isLast)
            } else {
                cell
                    .configure(
                        iconName: "phone",
                        text: "\(deals.mobileNumber)",
                        isLast: isLast
                    )
            }
            return cell

        case .deliverables:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DeliverableCell.reuseId,
                for: indexPath
            ) as! DeliverableCell

            let isLast = indexPath.item == deals.deliverables.count - 1
            cell.configure(with: deals.deliverables[indexPath.item], isLast: isLast)
            return cell

        case .selectedIdea:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "selectedIdeaCell",
                for: indexPath
            ) as! ScriptsCell1
            cell.configureCell(idea: selectedIdea!)
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
