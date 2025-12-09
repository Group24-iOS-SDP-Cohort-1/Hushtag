//
//  DealsInfo.swift
//  Hushtag
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit


private enum DealsInfoSection: Int, CaseIterable {
    case details
    case deliverables
}


class DealsInfo: UIViewController {
    
    var selectedIdea: Idea?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var deals: Deal!
    
    private var detailRegistration: UICollectionView.CellRegistration<DealDetailCell, (String, String)>!
        private var deliverableRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, Deliverable>!
        private var headerRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell>!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = deals.name
        collectionView.backgroundColor = .systemGroupedBackground
        view.backgroundColor = .systemGroupedBackground
                configureLayout()
                configureRegistrations()
                collectionView.allowsSelection = false
                collectionView.dataSource = self
                collectionView.delegate   = self
    }
}
extension DealsInfo {

    private func configureLayout() {
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.headerMode = .supplementary

            collectionView.collectionViewLayout =
                UICollectionViewCompositionalLayout.list(using: config)
        }

    private func configureRegistrations() {

        // DETAILS rows (Deadline, Payment, Gmail, Phone)
        detailRegistration =
        UICollectionView.CellRegistration<DealDetailCell, (String, String)> { cell, _, item in
            let (title, value) = item
            cell.configure(title: title, value: value)
        }

        // DELIVERABLE rows
        deliverableRegistration =
        UICollectionView.CellRegistration<UICollectionViewListCell, Deliverable> { cell, _, deliverable in
            var content = UIListContentConfiguration.subtitleCell()
            content.text = deliverable.name
            content.textProperties.font  = .systemFont(ofSize: 14, weight: .regular)
            content.textProperties.color = .label

            if let day = deliverable.deadline.day,
               let dateString = deliverable.deadline.date?.prefix(10) {
                content.secondaryText = "Due \(day) \(dateString)"
                content.secondaryTextProperties.color = .secondaryLabel
                content.secondaryTextProperties.font  = .systemFont(ofSize: 12, weight: .regular)
            } else {
                content.secondaryText = nil
            }

            // purple check circle like Figma
            let symbolName = deliverable.isCompleted ? "checkmark.circle.fill" : "circle"
            let purple = UIColor(red: 139/255, green: 92/255, blue: 246/255, alpha: 1)
            content.image = UIImage(systemName: symbolName)
            content.imageProperties.tintColor = purple
            content.imageProperties.preferredSymbolConfiguration =
                UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)

            content.imageToTextPadding = 8
            cell.contentConfiguration = content
            
        }

        // Section headers
        headerRegistration =
        UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { header, _, indexPath in

            guard let section = DealsInfoSection(rawValue: indexPath.section) else { return }

            var content = UIListContentConfiguration.header()
            switch section {
            case .details:
                content.text = "Details"
            case .deliverables:
                content.text = "Deliverables"
            }
            content.textProperties.font  = .systemFont(ofSize: 20, weight: .bold)
            content.textProperties.color = .label
            header.contentConfiguration = content
        }
    }
    // MARK: - Helpers

    private func overallDeadline() -> String {
        guard let last = deals.deliverable.last else { return "-" }
        let day  = last.deadline.day ?? ""
        let date = (last.deadline.date ?? "").prefix(10)
        return "\(day) \(date)"
    }

    private func formattedPayment() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        let amountString = formatter.string(from: deals.payment as NSNumber) ?? "\(deals.payment)"
        return "Rs \(amountString)"
    }

    /// Title + value for the "Details" card
    private var detailRows: [(String, String)] {
        [
            ("Deadline",      overallDeadline()),
            ("Payment",       formattedPayment()),
            ("Gmail",         deals.email),
            ("Phone number",  deals.phone)
        ]
    }
}

// MARK: - UICollectionViewDataSource
extension DealsInfo: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return DealsInfoSection.allCases.count    // details + deliverables
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        guard let sec = DealsInfoSection(rawValue: section) else { return 0 }

        switch sec {
        case .details:
            return detailRows.count
        case .deliverables:
            return deals.deliverable.count
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
            let deliverable = deals.deliverable[indexPath.item]
            return collectionView.dequeueConfiguredReusableCell(
                using: deliverableRegistration,
                for: indexPath,
                item: deliverable
            )
        }
    }

    // Headers for list layout
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        collectionView.dequeueConfiguredReusableSupplementary(
            using: headerRegistration,
            for: indexPath
        )
    }
}

// MARK: - UICollectionViewDelegate (if needed later)
extension DealsInfo: UICollectionViewDelegate {}
