import UIKit

extension Schedule: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return weekDates.count
        }
        return 2 // 2 action cards: New Post & Existing Script
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

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "scheduler_action_cell",
            for: indexPath
        )

        // Clean any existing subviews
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.contentView.layer.cornerRadius = 16
        cell.contentView.backgroundColor = UIColor.secondarySystemGroupedBackground
        cell.layer.masksToBounds = false

        let isNewPost = indexPath.row == 0
        let iconName = isNewPost ? "video.badge.plus" : "doc.text.fill"
        let title = isNewPost ? "Schedule New Video" : "From Scripted Ideas"
        let subtitle = isNewPost ?
            "Upload a video, custom thumbnail, and set publication date & time." :
            "Pick an AI-generated script from Ideate to prefill your video upload."
        let tintColor = isNewPost ?
            UIColor(red: 0.545, green: 0.361, blue: 0.965, alpha: 1.0) :
            UIColor.systemIndigo

        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = tintColor
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.preferredSymbolConfiguration = .init(pointSize: 26, weight: .semibold)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .tertiaryLabel
        chevron.contentMode = .scaleAspectFit
        chevron.preferredSymbolConfiguration = .init(pointSize: 14, weight: .semibold)
        chevron.translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let mainStack = UIStackView(arrangedSubviews: [iconImageView, textStack, chevron])
        mainStack.axis = .horizontal
        mainStack.spacing = 16
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 36),
            iconImageView.heightAnchor.constraint(equalToConstant: 36),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            mainStack.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 14),
            mainStack.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -14)
        ])

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

            headerView.configureHeader(text: "YouTube Video Scheduler")
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
            collectionView.reloadSections(IndexSet(integer: 0))
            return
        }

        if indexPath.section == 1 {
            if indexPath.row == 0 {
                handleNewPost()
            } else {
                handleExistingPost()
            }
        }
    }
}
