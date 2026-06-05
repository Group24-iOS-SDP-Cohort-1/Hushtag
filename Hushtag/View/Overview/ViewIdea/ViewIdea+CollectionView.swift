import UIKit

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension ViewIdea: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in _: UICollectionView) -> Int {
        if !shouldShowStats() && !shouldShowHashtags() {
            return 2
        }
        return 5
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 2 {
            return shouldShowStats() ? 2 : 0
        }
        if section == 3 {
            return shouldShowHashtags() ? 1 : 0
        }
        return 1
    }

    func collectionView(_: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0: return makeProgressCell(at: indexPath)
        case 1: return makeBasicInfoCell(at: indexPath)
        case 2: return makeStatisticsCell(at: indexPath)
        case 3: return makeHashtagCell(at: indexPath)
        default:
            return ideaView
                .dequeueReusableCell(withReuseIdentifier: "button", for: indexPath) as? IdeaDetailsCollectionViewCell
                ?? UICollectionViewCell()
        }
    }

    private func makeProgressCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = ideaView
            .dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? IdeaProgressCollectionViewCell
        else { return UICollectionViewCell() }

        let title: String
        if hasExistingScript {
            title = "View Draft"
        } else if hasStartedConversation {
            title = "Continue"
        } else {
            title = "Draft Script"
        }

        cell.configure(completedTypes: completedScriptTypes, buttonTitle: title)
        cell.onButtonTapped = { [weak self] in
            guard let self = self, let idea = self.idea else { return }
            self.handleDraftScriptTap(for: idea)
        }
        return cell
    }

    private func makeBasicInfoCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = ideaView
            .dequeueReusableCell(withReuseIdentifier: "basicInfo", for: indexPath) as? IdeaDetailsCollectionViewCell
        else { return UICollectionViewCell() }

        if let idea = idea { cell.configure(with: idea) }
        cell.onContentUpdated = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async { self.ideaView.performBatchUpdates(nil) }
        }
        return cell
    }

    private func makeStatisticsCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = ideaView
            .dequeueReusableCell(withReuseIdentifier: "statistics", for: indexPath) as? IdeaDetailsCollectionViewCell
        else { return UICollectionViewCell() }

        guard let idea = idea else { return cell }
        let values = statistics(with: idea)
        guard indexPath.row < values.count else { return cell }

        let symbols = ["eye", "hand.thumbsup"]
        cell.configureStatistic(values[indexPath.row], symbols[indexPath.row])
        cell.view.layer.cornerRadius = 16
        cell.view.layer.borderWidth = 0.5
        cell.view.backgroundColor = UIColor.accent.withAlphaComponent(0.1)
        cell.view.layer.borderColor = UIColor.accent.withAlphaComponent(1.0).cgColor
        return cell
    }

    private func makeHashtagCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = ideaView
            .dequeueReusableCell(withReuseIdentifier: "gaps", for: indexPath) as? IdeaDetailsCollectionViewCell
        else { return UICollectionViewCell() }

        cell.configureHashtag(idea?.hashtags ?? [])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == "header" else { return UICollectionReusableView() }

        let headerText: String
        switch indexPath.section {
        case 2: headerText = "Performance Statistics"
        case 3: headerText = "Trending Hashtags"
        default: return UICollectionReusableView()
        }

        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: "header",
            withReuseIdentifier: "headerCell",
            for: indexPath
        ) as? HeaderView else { return UICollectionReusableView() }

        headerView.configureHeader(text: headerText)
        return headerView
    }
}
