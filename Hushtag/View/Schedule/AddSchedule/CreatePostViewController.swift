import UIKit
import PhotosUI
import UniformTypeIdentifiers

class CreatePostViewController: UIViewController {

    // MARK: - Data
    private var selectedVideoURL: URL?
    private var selectedCategory: YouTubeCategory = .filmAndAnimation
    private var selectedPrivacy: String = "Public"

    enum YouTubeCategory: String, CaseIterable {
        case filmAndAnimation   = "Film & Animation"
        case autosAndVehicles   = "Autos & Vehicles"
        case music              = "Music"
        case petsAndAnimals     = "Pets & Animals"
        case sports             = "Sports"
        case gaming             = "Gaming"
        case travelAndEvents    = "Travel & Events"
        case peopleAndBlogs     = "People & Blogs"
        case comedy             = "Comedy"
        case entertainment      = "Entertainment"
        case newsAndPolitics    = "News & Politics"
        case howtoAndStyle      = "Howto & Style"
        case education          = "Education"
        case scienceAndTech     = "Science & Technology"
        case nonprofits         = "Nonprofits & Activism"

        var categoryId: String {
            switch self {
            case .filmAndAnimation:  return "1"
            case .autosAndVehicles:  return "2"
            case .music:             return "10"
            case .petsAndAnimals:    return "15"
            case .sports:            return "17"
            case .gaming:            return "20"
            case .travelAndEvents:   return "19"
            case .peopleAndBlogs:    return "22"
            case .comedy:            return "23"
            case .entertainment:     return "24"
            case .newsAndPolitics:   return "25"
            case .howtoAndStyle:     return "26"
            case .education:         return "27"
            case .scienceAndTech:    return "28"
            case .nonprofits:        return "29"
            }
        }
    }

    // MARK: - UI Components
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // Shared references to input fields from cells
    private weak var uploadVideoButton: UIButton?
    private weak var videoPreviewLabel: UILabel?
    private let titleTextView = UITextView()
    private let titlePlaceholder = UILabel()
    private let titleContainer = UIView()
    private let descriptionTextView = UITextView()
    private let descriptionPlaceholder = UILabel()
    private let descriptionContainer = UIView()
    private let tagsTextView = UITextView()
    private let tagsPlaceholder = UILabel()
    private let tagsContainer = UIView()
    private let privacyTextField = UITextField()
    private let publishAtDatePicker = UIDatePicker()
    
    private let dateFormatter = DateFormatter()
    
    enum Section: Int, CaseIterable {
        case media
        case postDetails
    }
    
    var currentFields = [
        "Title",
        "Description",
        "Tags",
        "Category",
        "Privacy Status",
        "Publish At"
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "New Post"
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        publishAtDatePicker.datePickerMode = .dateAndTime
        publishAtDatePicker.preferredDatePickerStyle = .wheels
        publishAtDatePicker.minimumDate = Date()

        buildLayout()
        setupNavigationBar()
        setupKeyboardHandling()
    }

    // MARK: - Layout & Navigation
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
    }

    private func setupDescriptionView() {
        descriptionContainer.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.font = .systemFont(ofSize: 16)
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 8, left: -4, bottom: 8, right: 0)
        descriptionTextView.delegate = self
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionPlaceholder.text = "Enter post description..."
        descriptionPlaceholder.font = .systemFont(ofSize: 16)
        descriptionPlaceholder.textColor = .placeholderText
        descriptionPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionContainer.addSubview(descriptionTextView)
        descriptionContainer.addSubview(descriptionPlaceholder)
        
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: descriptionContainer.topAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: descriptionContainer.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: descriptionContainer.trailingAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: descriptionContainer.bottomAnchor),
            descriptionPlaceholder.topAnchor.constraint(equalTo: descriptionContainer.topAnchor, constant: 8),
            descriptionPlaceholder.leadingAnchor.constraint(equalTo: descriptionContainer.leadingAnchor, constant: 0)
        ])
    }

    private func setupTitleView() {
        titleContainer.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        titleTextView.backgroundColor = .clear
        titleTextView.font = .systemFont(ofSize: 16)
        titleTextView.textContainerInset = UIEdgeInsets(top: 8, left: -4, bottom: 8, right: 0)
        titleTextView.delegate = self
        titleTextView.translatesAutoresizingMaskIntoConstraints = false
        
        titlePlaceholder.text = "Enter post title"
        titlePlaceholder.font = .systemFont(ofSize: 16)
        titlePlaceholder.textColor = .placeholderText
        titlePlaceholder.translatesAutoresizingMaskIntoConstraints = false
        
        titleContainer.addSubview(titleTextView)
        titleContainer.addSubview(titlePlaceholder)
        
        NSLayoutConstraint.activate([
            titleTextView.topAnchor.constraint(equalTo: titleContainer.topAnchor),
            titleTextView.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor),
            titleTextView.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor),
            titleTextView.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor),
            titlePlaceholder.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 8),
            titlePlaceholder.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 0)
        ])
    }

    private func setupTagsView() {
        tagsContainer.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        tagsTextView.backgroundColor = .clear
        tagsTextView.font = .systemFont(ofSize: 16)
        tagsTextView.textContainerInset = UIEdgeInsets(top: 8, left: -4, bottom: 8, right: 0)
        tagsTextView.delegate = self
        tagsTextView.translatesAutoresizingMaskIntoConstraints = false
        
        tagsPlaceholder.text = "Add tags separated by commas"
        tagsPlaceholder.font = .systemFont(ofSize: 16)
        tagsPlaceholder.textColor = .placeholderText
        tagsPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        
        tagsContainer.addSubview(tagsTextView)
        tagsContainer.addSubview(tagsPlaceholder)
        
        NSLayoutConstraint.activate([
            tagsTextView.topAnchor.constraint(equalTo: tagsContainer.topAnchor),
            tagsTextView.leadingAnchor.constraint(equalTo: tagsContainer.leadingAnchor),
            tagsTextView.trailingAnchor.constraint(equalTo: tagsContainer.trailingAnchor),
            tagsTextView.bottomAnchor.constraint(equalTo: tagsContainer.bottomAnchor),
            tagsPlaceholder.topAnchor.constraint(equalTo: tagsContainer.topAnchor, constant: 8),
            tagsPlaceholder.leadingAnchor.constraint(equalTo: tagsContainer.leadingAnchor, constant: 0)
        ])
    }

    private func updateFieldsBasedOnPrivacy() {
        let shouldShowPublishAt = (selectedPrivacy == "Public")
        let hasPublishAt = currentFields.contains("Publish At")
        
        if shouldShowPublishAt && !hasPublishAt {
            currentFields.append("Publish At")
            if let index = currentFields.firstIndex(of: "Publish At") {
                tableView.insertRows(at: [IndexPath(row: index, section: Section.postDetails.rawValue)], with: .automatic)
            }
        } else if !shouldShowPublishAt && hasPublishAt {
            if let index = currentFields.firstIndex(of: "Publish At") {
                currentFields.remove(at: index)
                tableView.deleteRows(at: [IndexPath(row: index, section: Section.postDetails.rawValue)], with: .automatic)
            }
        }
    }

    private func buildLayout() {
        setupTitleView()
        setupDescriptionView()
        setupTagsView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGroupedBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.register(PostFieldCell.self, forCellReuseIdentifier: "PostFieldCell")
        tableView.register(PostMediaCell.self, forCellReuseIdentifier: "PostMediaCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Actions
    @objc private func uploadVideoTapped() {
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func doneTapped() {
        view.endEditing(true)

        let title = titleTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let description = descriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let rawTags = tagsTextView.text ?? ""
        let parsedTags = rawTags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }

        print("📹 Video: \(String(describing: selectedVideoURL))")
        print("📝 Title: \(title)")
        print("📄 Description: \(description)")
        print("🏷️ Tags: \(parsedTags)")
        print("📂 Category: \(selectedCategory.categoryId)")
        print("🔒 Privacy: \(selectedPrivacy.lowercased())")
        print("📅 Publish At: \(publishAtDatePicker.date)")

        dismiss(animated: true)
    }

    // MARK: - Keyboard
    private func setupKeyboardHandling() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension CreatePostViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sec = Section(rawValue: section) else { return 0 }
        switch sec {
        case .media: return 1
        case .postDetails: return currentFields.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let sec = Section(rawValue: section) else { return nil }
        if sec == .postDetails {
            return "We will remind you 1 hr before"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostMediaCell", for: indexPath) as! PostMediaCell
            cell.uploadButton.addTarget(self, action: #selector(uploadVideoTapped), for: .touchUpInside)
            self.uploadVideoButton = cell.uploadButton
            self.videoPreviewLabel = cell.previewLabel
            
            if let url = selectedVideoURL {
                self.videoPreviewLabel?.text = "📹 \(url.lastPathComponent)"
                self.videoPreviewLabel?.isHidden = false
                self.uploadVideoButton?.setTitle("  Change Video", for: .normal)
            } else {
                self.videoPreviewLabel?.isHidden = true
                self.uploadVideoButton?.setTitle("  Upload Video", for: .normal)
            }
            return cell
            
        case .postDetails:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostFieldCell", for: indexPath) as! PostFieldCell
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
                
            case "Privacy Status":
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
                
            case "Publish At":
                cell.textField.textAlignment = .right
                cell.textField.text = dateFormatter.string(from: publishAtDatePicker.date)
                cell.textField.inputView = publishAtDatePicker
                cell.textField.inputAccessoryView = toolbar
                cell.setTitle("Publish At")
                publishAtDatePicker.addTarget(self, action: #selector(publishDateChanged), for: .valueChanged)
            default:
                break
            }
            
            return cell
        }
    }
    
    @objc func publishDateChanged() {
        if let index = currentFields.firstIndex(of: "Publish At") {
            let indexPath = IndexPath(row: index, section: Section.postDetails.rawValue)
            if let cell = tableView.cellForRow(at: indexPath) as? PostFieldCell {
                cell.textField.text = dateFormatter.string(from: publishAtDatePicker.date)
            }
        }
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

        let typeIdentifier = UTType.movie.identifier
        if result.itemProvider.hasItemConformingToTypeIdentifier(typeIdentifier) {
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { [weak self] url, error in
                guard let url = url, error == nil else { return }
                
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                try? FileManager.default.removeItem(at: tempURL) // Remove if already exists
                try? FileManager.default.copyItem(at: url, to: tempURL)

                DispatchQueue.main.async {
                    self?.selectedVideoURL = tempURL
                    self?.tableView.reloadSections(IndexSet(integer: Section.media.rawValue), with: .automatic)
                }
            }
        }
    }
}

// MARK: - Custom Cells
private class PostFieldCell: UITableViewCell {
    
    let textField = UITextField()
    private let titleLabel = UILabel()
    private var sharedTextField: UITextField?
    private var customView: UIView?
    private var overlayMenuButton: UIButton?
    
    private let stackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .secondarySystemGroupedBackground
        
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.isHidden = true
        
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.font = .systemFont(ofSize: 16)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(textField)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 24)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func resetAccessory() {
        textField.rightView = nil
        textField.rightViewMode = .never
        textField.inputView = nil
        textField.inputAccessoryView = nil
        textField.text = ""
        textField.isHidden = false
        textField.textAlignment = .left
        
        titleLabel.isHidden = true
        titleLabel.text = nil
        
        customView?.removeFromSuperview()
        customView = nil
        
        sharedTextField?.removeFromSuperview()
        sharedTextField = nil
        
        overlayMenuButton?.removeFromSuperview()
        overlayMenuButton = nil
    }
    
    func setTitle(_ text: String?) {
        if let text = text {
            titleLabel.text = text
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = true
        }
    }
    
    func install(textField shared: UITextField, title: String?) {
        self.textField.isHidden = true
        self.sharedTextField = shared
        shared.borderStyle = .none
        shared.backgroundColor = .clear
        shared.font = .systemFont(ofSize: 16)
        
        stackView.addArrangedSubview(shared)
        setTitle(title)
        
        // Remove previous shared text fields if they were left inside accidentally?
        // Since we remove them in `resetAccessory`, the new one is safely added.
    }
    
    func install(view: UIView) {
        self.textField.isHidden = true
        self.customView = view
        stackView.addArrangedSubview(view)
    }
    
    func addOverlay(_ button: UIButton) {
        self.overlayMenuButton = button
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

private class PostMediaCell: UITableViewCell {

    let uploadButton = UIButton(type: .system)
    let previewLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(container)
        
        uploadButton.setImage(UIImage(systemName: "video.badge.plus"), for: .normal)
        uploadButton.backgroundColor = .secondarySystemFill
        uploadButton.layer.cornerRadius = 12
        uploadButton.layer.masksToBounds = true
        uploadButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        uploadButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        previewLabel.font = .systemFont(ofSize: 14)
        previewLabel.textColor = .secondaryLabel
        previewLabel.isHidden = true
        
        container.addArrangedSubview(uploadButton)
        container.addArrangedSubview(previewLabel)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


