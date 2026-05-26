import PhotosUI
import UIKit
import UniformTypeIdentifiers

// MARK: - UITableViewDataSource & Delegate

extension CreatePostViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in _: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sec = Section(rawValue: section) else { return 0 }
        switch sec {
        case .media: return 1
        case .postDetails: return currentFields.count
        }
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 44
    }

    func tableView(_: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let sec = Section(rawValue: section) else { return nil }
        if sec == .postDetails {
            return "We will remind you 1 hr before"
        }
        return nil
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sec = Section(rawValue: section) else { return nil }
        let headerView = UIView()
        headerView.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        switch sec {
        case .media:
            titleLabel.text = "Media"
        case .postDetails:
            titleLabel.text = "Post Details"
        }

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])

        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sec = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        switch sec {
        case .media:
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: "PostMediaCell", for: indexPath) as? PostMediaCell
            else { return UITableViewCell() }
            return configureMediaCell(cell)
        case .postDetails:
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: "PostFieldCell", for: indexPath) as? PostFieldCell
            else { return UITableViewCell() }
            return configurePostDetailsCell(cell, at: indexPath)
        }
    }

    func configureMediaCell(_ cell: PostMediaCell) -> PostMediaCell {
        cell.uploadButton.addTarget(self, action: #selector(uploadVideoTapped), for: .touchUpInside)
        cell.removeButton.addTarget(self, action: #selector(removeVideoTapped), for: .touchUpInside)
        uploadVideoButton = cell.uploadButton
        videoPreviewLabel = cell.previewLabel

        if let url = selectedVideoURL {
            videoPreviewLabel?.text = "📹 \(url.lastPathComponent)"
            videoPreviewLabel?.isHidden = false
            cell.removeButton.isHidden = false
            uploadVideoButton?.setTitle("  Change Video", for: .normal)
        } else {
            videoPreviewLabel?.isHidden = true
            cell.removeButton.isHidden = true
            uploadVideoButton?.setTitle("  Upload Video", for: .normal)
        }

        cell.thumbnailUploadButton.addTarget(self, action: #selector(uploadThumbnailTapped), for: .touchUpInside)
        cell.thumbnailRemoveButton.addTarget(self, action: #selector(removeThumbnailTapped), for: .touchUpInside)
        uploadThumbnailButton = cell.thumbnailUploadButton
        thumbnailPreviewLabel = cell.thumbnailPreviewLabel

        if let url = selectedThumbnailURL {
            thumbnailPreviewLabel?.text = "🖼️ \(url.lastPathComponent)"
            thumbnailPreviewLabel?.isHidden = false
            cell.thumbnailRemoveButton.isHidden = false
            uploadThumbnailButton?.setTitle("  Change Thumbnail", for: .normal)
        } else {
            thumbnailPreviewLabel?.isHidden = true
            cell.thumbnailRemoveButton.isHidden = true
            uploadThumbnailButton?.setTitle("  Upload Thumbnail", for: .normal)
        }
        return cell
    }

    func configurePostDetailsCell(_ cell: PostFieldCell, at indexPath: IndexPath) -> PostFieldCell {
        let placeholder = currentFields[indexPath.row]
        cell.resetAccessory()

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPicker))
        toolbar.setItems([doneButton], animated: true)

        switch placeholder {
        case "Title":
            cell.install(view: titleContainer)
        case "Description":
            cell.install(view: descriptionContainer)
        case "Tags":
            cell.install(view: tagsContainer)
        case "Category":
            configureCategoryCell(cell)
        case "Privacy Status":
            configurePrivacyCell(cell)
        case "Publish At":
            configurePublishAtCell(cell, toolbar: toolbar)
        default:
            break
        }
        return cell
    }

    private func configureCategoryCell(_ cell: PostFieldCell) {
        cell.textField.textAlignment = .left
        cell.textField.text = selectedCategory.rawValue
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        let actions = YouTubeCategory.allCases.map { category in
            UIAction(title: category.rawValue) { [weak self, weak cell] _ in
                self?.selectedCategory = category
                cell?.textField.text = category.rawValue
            }
        }
        let menu = UIMenu(children: actions)
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
        cell.textField.rightView = button
        cell.textField.rightViewMode = .always
        cell.textField.isUserInteractionEnabled = true
        let overlayButton = UIButton(type: .custom)
        overlayButton.menu = menu
        overlayButton.showsMenuAsPrimaryAction = true
        cell.addOverlay(overlayButton)
    }

    private func configurePrivacyCell(_ cell: PostFieldCell) {
        privacyTextField.placeholder = "Privacy Status"
        privacyTextField.text = selectedPrivacy
        privacyTextField.textAlignment = .left
        cell.install(textField: privacyTextField, title: nil)
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        let privacyOptions = ["Public", "Private", "Unlisted"]
        let actions = privacyOptions.map { option in
            UIAction(title: option) { [weak self] _ in
                guard let self = self else { return }
                self.selectedPrivacy = option
                self.privacyTextField.text = option
                self.updateFieldsBasedOnPrivacy()
            }
        }
        let menu = UIMenu(children: actions)
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
        privacyTextField.rightView = button
        privacyTextField.rightViewMode = .always
        privacyTextField.isUserInteractionEnabled = true
        let overlayButton = UIButton(type: .custom)
        overlayButton.menu = menu
        overlayButton.showsMenuAsPrimaryAction = true
        cell.addOverlay(overlayButton)
    }

    private func configurePublishAtCell(_ cell: PostFieldCell, toolbar: UIToolbar) {
        cell.textField.textAlignment = .right
        cell.textField.text = dateFormatter.string(from: publishAtDatePicker.date)
        cell.textField.inputView = publishAtDatePicker
        cell.textField.inputAccessoryView = toolbar
        cell.setTitle("Publish At")
        publishAtDatePicker.addTarget(self, action: #selector(publishDateChanged), for: .valueChanged)
    }
}

// MARK: - UITextViewDelegate

extension CreatePostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView === titleTextView {
            titlePlaceholder.isHidden = !textView.text.isEmpty
        } else if textView === descriptionTextView {
            descriptionPlaceholder.isHidden = !textView.text.isEmpty
        } else if textView === tagsTextView {
            tagsPlaceholder.isHidden = !textView.text.isEmpty
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension CreatePostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }

        let videoType = UTType.movie.identifier
        let imageType = UTType.image.identifier

        if result.itemProvider.hasItemConformingToTypeIdentifier(videoType) {
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: videoType) { [weak self] url, error in
                guard let url = url, error == nil else { return }
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                try? FileManager.default.removeItem(at: tempURL)
                try? FileManager.default.copyItem(at: url, to: tempURL)

                DispatchQueue.main.async {
                    self?.selectedVideoURL = tempURL
                    self?.tableView.reloadSections(IndexSet(integer: Section.media.rawValue), with: .automatic)
                }
            }
        } else if result.itemProvider.hasItemConformingToTypeIdentifier(imageType) {
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: imageType) { [weak self] url, error in
                guard let url = url, error == nil else { return }
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                try? FileManager.default.removeItem(at: tempURL)
                try? FileManager.default.copyItem(at: url, to: tempURL)

                DispatchQueue.main.async {
                    self?.selectedThumbnailURL = tempURL
                    self?.tableView.reloadSections(IndexSet(integer: Section.media.rawValue), with: .automatic)
                }
            }
        }
    }
}
