import UIKit
import PhotosUI

class CreatePostViewController: UIViewController {

    // MARK: - Data
    private var selectedVideoURL: URL?
    private var selectedCategory: YouTubeCategory = .filmAndAnimation

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

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let buttonBar = UIView()

    private let uploadVideoButton = UIButton(type: .system)
    private let videoPreviewLabel = UILabel()
    private let titleTextField = UITextField()
    private let descriptionTextView = UITextView()
    private let descriptionPlaceholder = UILabel()
    private let tagsTextField = UITextField()
    private let categoryButton = UIButton(type: .system)
    private let privacySegmentedControl = UISegmentedControl(items: ["Public", "Private", "Unlisted"])
    private let publishAtDatePicker = UIDatePicker()
    private let reminderDatePicker = UIDatePicker()
    private let cancelButton = UIButton(type: .system)
    private let createPostButton = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "New Post"
        buildLayout()
        setupActions()
        setupKeyboardHandling()
    }

    // MARK: - Layout
    private func buildLayout() {
        // Scroll view
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Button bar
        buttonBar.backgroundColor = .secondarySystemBackground
        buttonBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonBar)

        // Content stack
        contentStack.axis = .vertical
        contentStack.spacing = 28
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        // Anchor button bar at bottom
        NSLayoutConstraint.activate([
            buttonBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonBar.heightAnchor.constraint(equalToConstant: 72),

            // Scroll view fills space above button bar
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonBar.topAnchor),

            // Content stack inside scroll view
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        // Build all sections
        contentStack.addArrangedSubview(makeVideoSection())
        contentStack.addArrangedSubview(makeField(label: "Title", field: titleTextField, placeholder: "Enter post title"))
        contentStack.addArrangedSubview(makeDescriptionSection())
        contentStack.addArrangedSubview(makeField(label: "Tags", field: tagsTextField, placeholder: "Add tags separated by commas"))
        contentStack.addArrangedSubview(makeCategorySection())
        contentStack.addArrangedSubview(makePrivacySection())
        contentStack.addArrangedSubview(makeDatePickerSection(label: "Publish At", picker: publishAtDatePicker))
        contentStack.addArrangedSubview(makeDatePickerSection(label: "Reminder", picker: reminderDatePicker))

        // Buttons inside button bar
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 17)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        var createConfig = UIButton.Configuration.filled()
        createConfig.title = "Create Post"
        createConfig.cornerStyle = .large
        createPostButton.configuration = createConfig
        createPostButton.translatesAutoresizingMaskIntoConstraints = false

        buttonBar.addSubview(cancelButton)
        buttonBar.addSubview(createPostButton)

        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: buttonBar.leadingAnchor, constant: 24),
            cancelButton.centerYAnchor.constraint(equalTo: buttonBar.centerYAnchor),

            createPostButton.trailingAnchor.constraint(equalTo: buttonBar.trailingAnchor, constant: -24),
            createPostButton.centerYAnchor.constraint(equalTo: buttonBar.centerYAnchor),
            createPostButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Section Builders
    private func makeVideoSection() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 12

        let label = sectionLabel("Video")
        container.addArrangedSubview(label)

        // Upload area
        uploadVideoButton.setTitle("  Upload Video", for: .normal)
        uploadVideoButton.setImage(UIImage(systemName: "video.badge.plus"), for: .normal)
        uploadVideoButton.backgroundColor = .secondarySystemFill
        uploadVideoButton.layer.cornerRadius = 12
        uploadVideoButton.layer.masksToBounds = true
        uploadVideoButton.titleLabel?.font = .systemFont(ofSize: 17)
        uploadVideoButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        container.addArrangedSubview(uploadVideoButton)

        videoPreviewLabel.text = ""
        videoPreviewLabel.font = .systemFont(ofSize: 14)
        videoPreviewLabel.textColor = .secondaryLabel
        videoPreviewLabel.isHidden = true
        container.addArrangedSubview(videoPreviewLabel)

        return container
    }

    private func makeField(label text: String, field: UITextField, placeholder: String) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8

        container.addArrangedSubview(sectionLabel(text))

        field.placeholder = placeholder
        field.borderStyle = .roundedRect
        field.font = .systemFont(ofSize: 16)
        field.heightAnchor.constraint(equalToConstant: 44).isActive = true
        container.addArrangedSubview(field)

        return container
    }

    private func makeDescriptionSection() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8

        container.addArrangedSubview(sectionLabel("Description"))

        let tvWrapper = UIView()
        tvWrapper.layer.cornerRadius = 10
        tvWrapper.layer.borderWidth = 0.5
        tvWrapper.layer.borderColor = UIColor.separator.cgColor
        tvWrapper.heightAnchor.constraint(equalToConstant: 100).isActive = true
        tvWrapper.layer.masksToBounds = true
        tvWrapper.backgroundColor = .secondarySystemBackground

        descriptionTextView.backgroundColor = .clear
        descriptionTextView.font = .systemFont(ofSize: 16)
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        descriptionTextView.delegate = self
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        tvWrapper.addSubview(descriptionTextView)

        descriptionPlaceholder.text = "Enter post description..."
        descriptionPlaceholder.font = .systemFont(ofSize: 16)
        descriptionPlaceholder.textColor = .placeholderText
        descriptionPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        tvWrapper.addSubview(descriptionPlaceholder)

        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: tvWrapper.topAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: tvWrapper.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: tvWrapper.trailingAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: tvWrapper.bottomAnchor),
            descriptionPlaceholder.topAnchor.constraint(equalTo: tvWrapper.topAnchor, constant: 14),
            descriptionPlaceholder.leadingAnchor.constraint(equalTo: tvWrapper.leadingAnchor, constant: 16)
        ])

        container.addArrangedSubview(tvWrapper)
        return container
    }

    private func makeCategorySection() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8

        container.addArrangedSubview(sectionLabel("Category"))

        var config = UIButton.Configuration.tinted()
        config.title = selectedCategory.rawValue
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.cornerStyle = .large
        categoryButton.configuration = config
        categoryButton.contentHorizontalAlignment = .leading

        let actions = YouTubeCategory.allCases.map { category in
            UIAction(title: category.rawValue) { [weak self] _ in
                self?.selectedCategory = category
                var c = self?.categoryButton.configuration
                c?.title = category.rawValue
                self?.categoryButton.configuration = c
            }
        }
        categoryButton.menu = UIMenu(title: "Select Category", children: actions)
        categoryButton.showsMenuAsPrimaryAction = true
        categoryButton.heightAnchor.constraint(equalToConstant: 44).isActive = true

        container.addArrangedSubview(categoryButton)
        return container
    }

    private func makePrivacySection() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8

        container.addArrangedSubview(sectionLabel("Privacy Status"))

        privacySegmentedControl.selectedSegmentIndex = 0
        container.addArrangedSubview(privacySegmentedControl)

        return container
    }

    private func makeDatePickerSection(label text: String, picker: UIDatePicker) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8

        container.addArrangedSubview(sectionLabel(text))

        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .compact
        container.addArrangedSubview(picker)

        return container
    }

    private func sectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }

    // MARK: - Actions
    private func setupActions() {
        uploadVideoButton.addTarget(self, action: #selector(uploadVideoTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        createPostButton.addTarget(self, action: #selector(createPostTapped), for: .touchUpInside)
    }

    @objc private func uploadVideoTapped() {
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func createPostTapped() {
        view.endEditing(true)

        let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let description = descriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let rawTags = tagsTextField.text ?? ""
        let parsedTags = rawTags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }

        let privacyOptions = ["public", "private", "unlisted"]
        let privacyStatus = privacySegmentedControl.selectedSegmentIndex >= 0
            ? privacyOptions[privacySegmentedControl.selectedSegmentIndex]
            : "public"

        print("📹 Video: \(String(describing: selectedVideoURL))")
        print("📝 Title: \(title)")
        print("📄 Description: \(description)")
        print("🏷️ Tags: \(parsedTags)")
        print("📂 Category: \(selectedCategory.categoryId)")
        print("🔒 Privacy: \(privacyStatus)")
        print("📅 Publish At: \(publishAtDatePicker.date)")
        print("🔔 Reminder: \(reminderDatePicker.date)")

        dismiss(animated: true)
    }

    // MARK: - Keyboard
    private func setupKeyboardHandling() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    @objc private func keyboardWillShow(_ n: Notification) {
        guard let frame = (n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        scrollView.contentInset.bottom = frame.height + 20
    }

    @objc private func keyboardWillHide() {
        scrollView.contentInset.bottom = 0
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UITextViewDelegate
extension CreatePostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descriptionPlaceholder.isHidden = !textView.text.isEmpty
    }
}

// MARK: - PHPickerViewControllerDelegate
extension CreatePostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }

        result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.movie") { [weak self] url, _ in
            guard let url = url else { return }
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
            try? FileManager.default.copyItem(at: url, to: tempURL)

            DispatchQueue.main.async {
                self?.selectedVideoURL = tempURL
                self?.videoPreviewLabel.text = "📹 \(tempURL.lastPathComponent)"
                self?.videoPreviewLabel.isHidden = false
                self?.uploadVideoButton.setTitle("  Change Video", for: .normal)
            }
        }
    }
}
