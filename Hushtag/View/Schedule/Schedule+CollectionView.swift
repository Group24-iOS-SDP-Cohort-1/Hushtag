import UIKit

extension Schedule: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return weekDates.count
        }
        return todayItems.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: "calendar", for: indexPath) as? CalendarCell
            else {
                return UICollectionViewCell()
            }

            let date = weekDates[indexPath.row]
            let calendar = Calendar.current

            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE"

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d"

            let dayText = dayFormatter.string(from: date).uppercased()
            let dateText = dateFormatter.string(from: date)

            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)

            cell.configure(
                day: dayText,
                date: dateText,
                isSelected: isSelected
            )

            return cell
        }

        if todayItems.isEmpty {
            return UICollectionViewCell()
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "upcoming_schedule",
            for: indexPath
        ) as? ScheduleCollectionViewCell else {
            return UICollectionViewCell()
        }

        let item = todayItems[indexPath.row]
        cell.delegate = self
        cell.indexPath = indexPath
        cell.configure(with: item)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == "header", indexPath.section == 1 {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: "header",
                withReuseIdentifier: "headerCell",
                for: indexPath
            ) as? HeaderView else {
                return UICollectionReusableView()
            }

            headerView.configureHeader(text: "Activities Overview")
            return headerView
        }

        if kind == "headerButton", indexPath.section == 0 {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: "headerButton",
                withReuseIdentifier: "header_button",
                for: indexPath
            ) as? HeaderButton else {
                return UICollectionReusableView()
            }

            headerView.configure(text: currentMonthText, date: selectedDate)

            headerView.onDateChanged = { [weak self] newDate in
                self?.changeMonth(to: newDate)
            }

            return headerView
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedDate = weekDates[indexPath.row]
            todayItems = scheduleController.scheduleItems(on: selectedDate)

            collectionView.performBatchUpdates {
                collectionView.reloadSections(IndexSet([0, 1]))
                self.updateEmptyState()
            }
            return
        }

        guard indexPath.section == 1,
              !todayItems.isEmpty else { return }

        selectedScheduleItem = todayItems[indexPath.row]
        performSegue(withIdentifier: "goToDetails", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "goToDetails" {
            guard let detailsVC = segue.destination as? Details else { return }
            detailsVC.schedule = selectedScheduleItem
            setupDetailsToggles(detailsVC: detailsVC)
        }
    }

    private func setupDetailsToggles(detailsVC: Details) {
        // Deliverable Toggle
        detailsVC.onToggleDeliverable = { [weak self, weak detailsVC] deal, deliverable in
            Task {
                await self?.handleDeliverableToggle(deal: deal, deliverable: deliverable)
                if let updatedDeal = self?.scheduleController.getDeal(id: deal.id) {
                    await MainActor
                        .run {
                            detailsVC?.schedule = .deal(deal: updatedDeal, deliverable: nil)
                            detailsVC?.detailsView.reloadData()
                        }
                }
            }
        }
        // Main Deal Toggle
        detailsVC.onToggleMainDeal = { [weak self, weak detailsVC] deal in
            Task {
                await self?.handleMainDealToggle(deal: deal)
                if let updatedDeal = self?.scheduleController.getDeal(id: deal.id) {
                    await MainActor
                        .run {
                            detailsVC?.schedule = .deal(deal: updatedDeal, deliverable: nil)
                            detailsVC?.detailsView.reloadData()
                        }
                }
            }
        }
    }
}

extension Schedule: ScheduleCollectionViewCellDelegate {
    func didTapCompleted(item: ScheduleItem, indexPath _: IndexPath) {
        Task {
            switch item {
            case let .deal(deal, deliverable):
                if let deliverable = deliverable {
                    await handleDeliverableToggle(deal: deal, deliverable: deliverable)
                } else {
                    await handleMainDealToggle(deal: deal)
                }
            }
        }
    }
}
