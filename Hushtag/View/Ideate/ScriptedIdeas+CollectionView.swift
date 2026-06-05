import UIKit

extension ScriptedIdeas: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let section = sections[indexPath.section]

        switch section {
        case .title:
            return titleCell(for: indexPath, in: collectionView)
        case .buttons:
            return buttonsCell(for: indexPath, in: collectionView)
        case .description:
            return contentCell(for: indexPath, in: collectionView, isScript: false)
        case .script:
            return contentCell(for: indexPath, in: collectionView, isScript: true)
        }
    }

    private func titleCell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "title", for: indexPath) as? ViewScriptsCell
        else {
            return UICollectionViewCell()
        }

        cell.configureTitle(with: idea?.title ?? "")
        cell.setEditingMode(isEditingMode, isTitle: true)
        cell.textChangedHandler = { [weak self] newText in
            self?.idea?.title = newText
        }
        return cell
    }

    private func buttonsCell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "buttons", for: indexPath) as? ViewScriptsCell
        else {
            return UICollectionViewCell()
        }

        setupTagDealMenu(for: cell)

        return cell
    }

    private func contentCell(
        for indexPath: IndexPath,
        in collectionView: UICollectionView,
        isScript: Bool
    ) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "content", for: indexPath) as? ViewScriptsCell
        else {
            return UICollectionViewCell()
        }

        cell.readMoreButton.tag = indexPath.section
        cell.readMoreButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

        if isScript {
            cell.configure(with: idea?.script ?? "")

            if isScriptExpanded {
                cell.content.numberOfLines = 0
                cell.readMoreButton.setTitle("Show Less", for: .normal)
            } else {
                cell.content.numberOfLines = 8
                cell.readMoreButton.setTitle("Read More", for: .normal)
            }

            cell.setEditingMode(isEditingMode, isTitle: false)
            cell.textChangedHandler = { [weak self] newText in
                self?.idea?.script = newText
            }
        } else {
            cell.configure(with: idea?.description ?? "")

            if isDescriptionExpanded {
                cell.content.numberOfLines = 0
                cell.readMoreButton.setTitle("Show Less", for: .normal)
            } else {
                cell.content.numberOfLines = 8
                cell.readMoreButton.setTitle("Read More", for: .normal)
            }

            cell.setEditingMode(isEditingMode, isTitle: false)
            cell.textChangedHandler = { [weak self] newText in
                self?.idea?.description = newText
            }
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == "header" else { return UICollectionReusableView() }

        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: "header",
            withReuseIdentifier: "headerCell",
            for: indexPath
        ) as? HeaderView else {
            return UICollectionReusableView()
        }

        let section = sections[indexPath.section]

        switch section {
        case .description:
            headerView.configureHeader(text: "Description")
        case .script:
            headerView.configureHeader(text: "Script")
        default:
            headerView.configureHeader(text: "")
        }

        return headerView
    }
}
