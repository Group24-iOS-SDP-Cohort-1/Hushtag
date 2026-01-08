//
//  DealsInfo.swift
//  Hushtag
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

let purple = UIColor(red: 139/255, green: 92/255, blue: 246/255, alpha: 1)

protocol DealsInfoDelegate: AnyObject {
    func dealsInfo(_ controller: DealsInfo, didUpdateDeal deal: Deal, at index: Int)
}

private let cardBackgroundElementKind = "card-background"

// MARK: - Card Background (Liquid Glass – MATCHES MAIN)

final class CardBackgroundView: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        layer.cornerRadius = 12
        clipsToBounds = true
        applyLiquidGlassEffect()
    }
}

private enum DealsInfoSection: Int, CaseIterable {
    case details
    case deliverables
    case selectedIdeas
    case notes
}

class DealsInfo: UIViewController {

    var selectedIdea: Idea?
    weak var delegate: DealsInfoDelegate?
    var dealIndex: Int = -1

    @IBOutlet weak var collectionView: UICollectionView!
    var deals: Deal?

    // ✅ MATCH MAIN: Use UICollectionViewListCell
    private var detailRegistration:
        UICollectionView.CellRegistration<UICollectionViewListCell, (String, String)>!

    private var deliverableRegistration:
        UICollectionView.CellRegistration<UICollectionViewListCell, Deliverable>!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = deals?.name
        view.backgroundColor = .clear
        collectionView.backgroundColor = .clear

        configureLayout()
        configureRegistrations()

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(
            UINib(nibName: "ScriptsCell1", bundle: nil),
            forCellWithReuseIdentifier: "ideaCell"
        )

        collectionView.register(
            UINib(nibName: "HeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "headerCell"
        )

        collectionView.register(NotesCell.self, forCellWithReuseIdentifier: "NotesCell")
    }
}

// MARK: - Layout

extension DealsInfo {

    private func configureLayout() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in

            guard let sectionKind = DealsInfoSection(rawValue: sectionIndex) else {
                return nil
            }

            var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
            listConfig.headerMode = .supplementary
            listConfig.backgroundColor = .clear

            let section = NSCollectionLayoutSection.list(
                using: listConfig,
                layoutEnvironment: environment
            )

            section.contentInsets = NSDirectionalEdgeInsets(
                top: 12,
                leading: 16,
                bottom: -11,
                trailing: 16
            )

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            )

            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )

            header.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 16,
                bottom: 0,
                trailing: 0
            )

            section.boundarySupplementaryItems = [header]

            if sectionKind == .details || sectionKind == .deliverables {
                let background = NSCollectionLayoutDecorationItem.background(
                    elementKind: cardBackgroundElementKind
                )
                background.contentInsets = NSDirectionalEdgeInsets(
                    top: 64,
                    leading: 16,
                    bottom: -10,
                    trailing: 16
                )
                section.decorationItems = [background]
            }

            return section
        }

        layout.register(
            CardBackgroundView.self,
            forDecorationViewOfKind: cardBackgroundElementKind
        )

        collectionView.collectionViewLayout = layout
    }
}

// MARK: - Cell Registrations (APPEARANCE MATCH)

extension DealsInfo {

    private func configureRegistrations() {

        // 🔹 DETAILS (SF Symbol + Value ONLY)
        detailRegistration =
        UICollectionView.CellRegistration<UICollectionViewListCell, (String, String)> {
            cell, _, item in

            let (title, value) = item

            var content = UIListContentConfiguration.valueCell()
            content.text = value
            content.textProperties.font = .systemFont(ofSize: 14)
            content.textProperties.color = .label

            // Map title → SF Symbol (DATA UNCHANGED)
            let symbolName: String
            switch title {
            case "Deadline":     symbolName = "calendar"
            case "Payment":      symbolName = "creditcard"
            case "Gmail":        symbolName = "envelope"
            case "Phone number": symbolName = "phone"
            default:             symbolName = "circle"
            }

            content.image = UIImage(systemName: symbolName)
            content.imageProperties.tintColor = purple
            content.imageProperties.preferredSymbolConfiguration =
                UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
            content.imageToTextPadding = 12

            cell.contentConfiguration = content
            cell.backgroundConfiguration = .clear()
        }

        // 🔹 DELIVERABLES (unchanged, already matching)
        deliverableRegistration =
        UICollectionView.CellRegistration<UICollectionViewListCell, Deliverable> {
            cell, _, deliverable in

            var content = UIListContentConfiguration.subtitleCell()
            content.text = deliverable.name
            content.textProperties.font = .systemFont(ofSize: 14)
            content.textProperties.color = .label

            if let day = deliverable.deadline.day,
               let date = deliverable.deadline.date?.prefix(10) {
                content.secondaryText = "Due \(day) \(date)"
            }

            let symbol = deliverable.isCompleted
                ? "circle.inset.filled"
                : "circle"

            content.image = UIImage(systemName: symbol)
            content.imageProperties.tintColor = purple
            content.imageProperties.preferredSymbolConfiguration =
                UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)

            cell.contentConfiguration = content
            cell.backgroundConfiguration = .clear()
        }
    }
}

// MARK: - DATA (UNCHANGED)

extension DealsInfo {

    private func overallDeadline() -> String {
        guard let last = deals?.deliverable.last else { return "-" }
        return "\(last.deadline.day ?? "") \(last.deadline.date?.prefix(10) ?? "")"
    }

    private func formattedPayment() -> String {
        guard let deal = deals else { return "-" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return "Rs \(formatter.string(from: deal.payment as NSNumber) ?? "\(deal.payment)")"
    }

    private var notesText: String? {
        deals?.description.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // ✅ DATA FETCHING UNCHANGED
    private var detailRows: [(String, String)] {
        guard let deal = deals else { return [] }
        return [
            ("Payment", formattedPayment()),
            ("Gmail", deal.email),
            ("Phone number", deal.phone)
        ]
    }
}
extension DealsInfo: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return DealsInfoSection.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        guard let sec = DealsInfoSection(rawValue: section) else { return 0 }
        
        switch sec {
        case .details:
            return detailRows.count
        case .deliverables:
            return deals?.deliverable.count ?? 0
        case .selectedIdeas:
            return selectedIdea != nil ? 1 : 0
        case .notes:
            return notesText != nil ? 1 : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let sec = DealsInfoSection(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        switch sec {
        case .details:
            let item = detailRows[indexPath.item]
            return collectionView.dequeueConfiguredReusableCell(
                using: detailRegistration,
                for: indexPath,
                item: item
            )
            
        case .deliverables:
            guard let deliverable = deals?.deliverable[indexPath.item] else {
                return UICollectionViewCell()
            }
            return collectionView.dequeueConfiguredReusableCell(
                using: deliverableRegistration,
                for: indexPath,
                item: deliverable
            )
            
        case .selectedIdeas:
            guard let idea = selectedIdea else { return UICollectionViewCell() }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ideaCell", for: indexPath)
            if let ideaCell = cell as? ScriptsCell1 {
                ideaCell.configureCell(idea: idea)
            }
            return cell
            
        case .notes:
            guard let note = notesText else { return UICollectionViewCell() }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotesCell", for: indexPath) as! NotesCell
            cell.label.text = note
            cell.backgroundColor = .clear
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader,
              let section = DealsInfoSection(rawValue: indexPath.section) else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "headerCell",
            for: indexPath
        ) as! HeaderView
        
        switch section {
        case .details:
            header.configureHeader(text: "Details")
        case .deliverables:
            header.configureHeader(text: "Deliverables")
        case .selectedIdeas:
            header.configureHeader(text: "Selected ideas")
        case .notes:
            header.configureHeader(text: "Notes")
        }
            
        return header
    }
}

// MARK: - Delegate (selection only for Deliverables)

extension DealsInfo: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let section = DealsInfoSection(rawValue: indexPath.section) else { return false }
        return section == .deliverables
    }

    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let section = DealsInfoSection(rawValue: indexPath.section) else { return false }
        return section == .deliverables
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let section = DealsInfoSection(rawValue: indexPath.section),
              section == .deliverables else { return }

        // Toggle state safely
        deals?.deliverable[indexPath.item].isCompleted.toggle()

        collectionView.reloadItems(at: [indexPath])

        // Notify parent
        if let updatedDeal = deals, dealIndex >= 0 {
            delegate?.dealsInfo(self, didUpdateDeal: updatedDeal, at: dealIndex)
        }
    }
}

