import UIKit

extension DealsInfo: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        sections.count
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]

        switch type {
        case .details: return 4
        case .deliverables: return deals.deliverables.count
        case .selectedIdeas: return selectedIdeas.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let type = sections[indexPath.section]

        switch type {
        case .details:
            return configureDetailsCell(collectionView, at: indexPath)
        case .deliverables:
            return configureDeliverableCell(collectionView, at: indexPath)
        case .selectedIdeas:
            return configureSelectedIdeaCell(collectionView, at: indexPath)
        }
    }

    private func configureDetailsCell(
        _ collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "DetailsCell", for: indexPath) as? DetailsCell
        else {
            return UICollectionViewCell()
        }

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
    }

    private func configureDeliverableCell(
        _ collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DeliverableCell.reuseId,
            for: indexPath
        ) as? DeliverableCell else {
            return UICollectionViewCell()
        }

        let isLast = indexPath.item == deals.deliverables.count - 1
        let deliverable = deals.deliverables[indexPath.item]

        cell.configure(with: deliverable, isLast: isLast)

        cell.onToggleStatus = { [weak self] in
            guard let self = self else { return }

            self.deals.deliverables[indexPath.item].isCompleted.toggle()
            let toggledDeliverable = self.deals.deliverables[indexPath.item]
            cell.updateStatus(isCompleted: toggledDeliverable.isCompleted)

            Task {
                do {
                    try await DealsController().updateDeliverableStatus(
                        deliverableId: toggledDeliverable.id,
                        isCompleted: toggledDeliverable.isCompleted
                    )

                    let currentDealIsCompleted = self.deals.isCompleted
                    try await DealsController().updateDealStatus(
                        dealId: self.deals.id,
                        isCompleted: currentDealIsCompleted
                    )

                    await MainActor.run {
                        if self.dealIndex >= 0 {
                            self.delegate?.dealsInfo(self, didUpdateDeal: self.deals, at: self.dealIndex)
                        }
                        NotificationCenter.default.post(name: .dealsDidChange, object: nil)
                    }

                } catch {
                    // error
                }
            }
        }

        return cell
    }

    private func configureSelectedIdeaCell(
        _ collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "selectedIdeaCell",
            for: indexPath
        ) as? ScriptsCell1 else {
            return UICollectionViewCell()
        }
        let idea = selectedIdeas[indexPath.item]
        cell.configureCell(with: idea)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "headerCell",
            for: indexPath
        ) as? HeaderView else {
            return UICollectionReusableView()
        }

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
    func collectionView(
        _: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        let section = sections[indexPath.section]
        return section == .deliverables || section == .selectedIdeas
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let section = sections[indexPath.section]

        if section == .selectedIdeas {
            let idea = selectedIdeas[indexPath.item]
            let storyboard = UIStoryboard(name: "Ideate", bundle: nil)
            guard let viewController = storyboard
                .instantiateViewController(withIdentifier: "scriptedIdea") as? ScriptedIdeas
            else { return }
            viewController.idea = idea
            viewController.isModal = true
            viewController.onDealUntagged = { [weak self] in
                self?.fetchLinkedIdeas()
            }
            let nav = UINavigationController(rootViewController: viewController)
            nav.modalPresentationStyle = .pageSheet
            present(nav, animated: true)
            return
        }

        guard section == .deliverables else { return }

        deals.deliverables[indexPath.item].isCompleted.toggle()
        let toggledDeliverable = deals.deliverables[indexPath.item]
        collectionView.reloadItems(at: [indexPath])

        Task {
            do {
                try await DealsController().updateDeliverableStatus(
                    deliverableId: toggledDeliverable.id,
                    isCompleted: toggledDeliverable.isCompleted
                )

                let currentDealIsCompleted = deals.isCompleted
                try await DealsController().updateDealStatus(
                    dealId: deals.id,
                    isCompleted: currentDealIsCompleted
                )

                await MainActor.run {
                    if dealIndex >= 0 {
                        delegate?.dealsInfo(self, didUpdateDeal: deals, at: dealIndex)
                    }
                    NotificationCenter.default.post(name: .dealsDidChange, object: nil)
                }
            } catch {
                // error
            }
        }
    }
}

extension DealsInfo: AddDealsDelegate {
    func addDealsViewController(
        _: AddDealsViewController,
        didUpdateDeal deal: Deal,
        at _: Int
    ) {
        deals = deal
        title = deal.name
        updateButtonState()
        collectionView.reloadData()

        if dealIndex >= 0 {
            delegate?.dealsInfo(self, didUpdateDeal: deal, at: -1)
        }

        dismiss(animated: true)
    }

    func addDealsViewController(
        _: AddDealsViewController,
        didCreateDeal _: Deal
    ) {}
}
