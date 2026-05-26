import PhotosUI
import UIKit
import UniformTypeIdentifiers

class CreatePostViewController: UIViewController {
    // MARK: - Data

    var selectedVideoURL: URL?
    var selectedThumbnailURL: URL?
    var selectedCategory: YouTubeCategory = .filmAndAnimation
    var selectedPrivacy: String = "Public"

    enum YouTubeCategory: String, CaseIterable {
        case filmAndAnimation = "Film & Animation"
        case autosAndVehicles = "Autos & Vehicles"
        case music = "Music"
        case petsAndAnimals = "Pets & Animals"
        case sports = "Sports"
        case gaming = "Gaming"
        case travelAndEvents = "Travel & Events"
        case peopleAndBlogs = "People & Blogs"
        case comedy = "Comedy"
        case entertainment = "Entertainment"
        case newsAndPolitics = "News & Politics"
        case howtoAndStyle = "Howto & Style"
        case education = "Education"
        case scienceAndTech = "Science & Technology"
        case nonprofits = "Nonprofits & Activism"

        var categoryId: String {
            switch self {
            case .filmAndAnimation: return "1"
            case .autosAndVehicles: return "2"
            case .music: return "10"
            case .petsAndAnimals: return "15"
            case .sports: return "17"
            case .gaming: return "20"
            case .travelAndEvents: return "19"
            case .peopleAndBlogs: return "22"
            case .comedy: return "23"
            case .entertainment: return "24"
            case .newsAndPolitics: return "25"
            case .howtoAndStyle: return "26"
            case .education: return "27"
            case .scienceAndTech: return "28"
            case .nonprofits: return "29"
            }
        }
    }

    // MARK: - UI Components

    let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // Shared references to input fields from cells
    weak var uploadVideoButton: UIButton?
    weak var videoPreviewLabel: UILabel?
    weak var uploadThumbnailButton: UIButton?
    weak var thumbnailPreviewLabel: UILabel?
    let titleTextView = UITextView()
    let titlePlaceholder = UILabel()
    let titleContainer = UIView()
    let descriptionTextView = UITextView()
    let descriptionPlaceholder = UILabel()
    let descriptionContainer = UIView()
    let tagsTextView = UITextView()
    let tagsPlaceholder = UILabel()
    let tagsContainer = UIView()
    let privacyTextField = UITextField()
    let publishAtDatePicker = UIDatePicker()

    let dateFormatter = DateFormatter()

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

    func prefill(title: String?, description: String?) {
        if let title = title {
            titleTextView.text = title
            titlePlaceholder.isHidden = !title.isEmpty
        }

        if let description = description {
            descriptionTextView.text = description
            descriptionPlaceholder.isHidden = !description.isEmpty
        }
    }

    // MARK: - Layout & Navigation

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
    }

    func updateFieldsBasedOnPrivacy() {
        let shouldShowPublishAt = (selectedPrivacy == "Public")
        let hasPublishAt = currentFields.contains("Publish At")

        if shouldShowPublishAt, !hasPublishAt {
            currentFields.append("Publish At")
            if let index = currentFields.firstIndex(of: "Publish At") {
                tableView.insertRows(
                    at: [IndexPath(row: index, section: Section.postDetails.rawValue)],
                    with: .automatic
                )
            }
        } else if !shouldShowPublishAt, hasPublishAt {
            if let index = currentFields.firstIndex(of: "Publish At") {
                currentFields.remove(at: index)
                tableView.deleteRows(
                    at: [IndexPath(row: index, section: Section.postDetails.rawValue)],
                    with: .automatic
                )
            }
        }
    }

    // MARK: - Actions

    @objc func uploadVideoTapped() {
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc func removeVideoTapped() {
        selectedVideoURL = nil
        tableView.reloadSections(IndexSet(integer: Section.media.rawValue), with: .automatic)
    }

    @objc func uploadThumbnailTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc func removeThumbnailTapped() {
        selectedThumbnailURL = nil
        tableView.reloadSections(IndexSet(integer: Section.media.rawValue), with: .automatic)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func doneTapped() {
        view.endEditing(true)

        let title = titleTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        var missingFields = [String]()

        if title.isEmpty { missingFields.append("Title") }
        if selectedVideoURL == nil { missingFields.append("Video") }

        if !missingFields.isEmpty {
            let message = "Please provide the following mandatory fields: \(missingFields.joined(separator: ", "))"
            let alert = UIAlertController(title: "Missing Fields", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let description = descriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let rawTags = tagsTextView.text ?? ""
        let parsedTags = rawTags.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
            .filter { !$0.isEmpty }

        let publishAt: Date? = currentFields.contains("Publish At") ? publishAtDatePicker.date : nil

        if let videoURL = selectedVideoURL {
            YouTubeUploadManager.shared.uploadVideo(request: VideoUploadRequest(
                videoURL: videoURL,
                thumbnailURL: selectedThumbnailURL,
                title: title,
                description: description.isEmpty ? nil : description,
                tags: parsedTags.isEmpty ? nil : parsedTags,
                categoryId: selectedCategory.categoryId,
                privacyStatus: selectedPrivacy,
                publishAt: publishAt
            ))
        }

        dismiss(animated: true)
    }

    // MARK: - Keyboard

    private func setupKeyboardHandling() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func dismissPicker() {
        view.endEditing(true)
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
