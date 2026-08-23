import UIKit

extension Details: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        switch schedule {
        case .deal:
            return 3
        case .youtubeUpload:
            return 1
        default:
            return 0
        }
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let schedule else { return 0 }

        if section == 0 {
            return 1
        }
        switch schedule {
        case let .deal(deal, _):
            if section == 1 {
                return 1
            }
            return deal.deliverables.count
        case .youtubeUpload:
            return 1
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let schedule = schedule else {
            return UICollectionViewCell()
        }

        switch schedule {
        case let .deal(deal, _):
            return dealCell(at: indexPath, deal: deal, schedule: schedule, in: collectionView)
        case let .youtubeUpload(upload):
            return youtubeCommonCell(at: indexPath, upload: upload, schedule: schedule, in: collectionView)
        }
    }

    // MARK: - Cell helpers

    private func dealCell(
        at indexPath: IndexPath,
        deal: Deal,
        schedule: ScheduleItem,
        in collectionView: UICollectionView
    ) -> UICollectionViewCell {
        if indexPath.section == 0 {
            return dealCommonCell(at: indexPath, schedule: schedule, in: collectionView)
        }

        if indexPath.section == 1 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "deal_details",
                for: indexPath
            ) as? DetailsCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.dealDetails(with: deal)
            return cell
        }

        return dealDeliverableCell(at: indexPath, deal: deal, in: collectionView)
    }

    private func dealCommonCell(
        at indexPath: IndexPath,
        schedule: ScheduleItem,
        in collectionView: UICollectionView
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "common_details",
            for: indexPath
        ) as? DetailsCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.indexPath = indexPath
        cell.onToggleCompletion = { [weak self] _ in
            guard let self else { return }
            guard case let .deal(deal, _) = self.schedule else { return }
            Task { await self.handleMainDealToggle(deal: deal) }
        }
        cell.configureCommon(with: schedule)
        cell.onDeleteTapped = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Delete Deal?",
                    message: "This will permanently delete the deal and all its deliverables.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                    guard case let .deal(deal, _) = self.schedule else { return }
                    self.performDelete(dealId: deal.id)
                })
                self.topMostViewController.present(alert, animated: true)
            }
        }
        cell.onEditTapped = { [weak self] in
            self?.performSegue(withIdentifier: "editDeal", sender: self)
        }
        return cell
    }

    private func youtubeCommonCell(
        at indexPath: IndexPath,
        upload: YouTubeUpload,
        schedule: ScheduleItem,
        in collectionView: UICollectionView
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "common_details",
            for: indexPath
        ) as? DetailsCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.indexPath = indexPath
        cell.configureCommon(with: schedule)
        cell.statusButton?.isHidden = true

        cell.onDeleteTapped = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Delete YouTube Video?",
                    message: "This will permanently delete this video from YouTube and your schedule.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                    self.performDeleteYouTubeUpload(upload: upload)
                })
                self.topMostViewController.present(alert, animated: true)
            }
        }

        cell.onEditTapped = { [weak self] in
            guard let self else { return }
            let editVC = CreatePostViewController()
            editVC.editingUpload = upload
            let nav = UINavigationController(rootViewController: editVC)
            self.present(nav, animated: true)
        }

        return cell
    }

    private func dealDeliverableCell(
        at indexPath: IndexPath,
        deal: Deal,
        in collectionView: UICollectionView
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "multiple_details",
            for: indexPath
        ) as? DetailsCollectionViewCell else {
            return UICollectionViewCell()
        }
        let deliverable = deal.deliverables[indexPath.row]
        cell.indexPath = indexPath
        cell.configureMultiple(with: deliverable)
        cell.onToggleCompletion = { [weak self] indexPath in
            guard let self else { return }
            guard case let .deal(deal, _) = self.schedule else { return }
            let deliverable = deal.deliverables[indexPath.row]
            Task { await self.handleDeliverableToggle(deal: deal, deliverable: deliverable) }
        }
        cell.applyLiquidGlassEffect()
        return cell
    }
}

extension Details: AddDealsDelegate {
    func addDealsViewController(_: AddDealsViewController, didCreateDeal _: Deal) {}

    func addDealsViewController(_: AddDealsViewController, didUpdateDeal deal: Deal, at _: Int) {
        guard case let .deal(_, currentDeliverable) = schedule else { return }

        // CHANGED: Handle optional deliverable
        let updatedDeliverable = currentDeliverable != nil ?
            (deal.deliverables.first(where: { $0.id == currentDeliverable!.id }) ?? currentDeliverable) : nil

        schedule = .deal(deal: deal, deliverable: updatedDeliverable)
        detailsView.reloadData()
    }
}

extension UIViewController {
    var topMostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController
        }
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController ?? tab
        }
        return self
    }
}
