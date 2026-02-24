import UIKit


//sending the create post to parent view controller
protocol AddViewDelegate: AnyObject {
    func addViewController(_ controller: AddViewController, didCreatePost post: Post)
    func addViewController(_ controller: AddViewController, didUpdatePost post: Post,at index: Int)
}

class AddViewController: UITableViewController, DeliverableCellAddDealDelegate {
    
    weak var delegate: AddViewDelegate?
    var editingPost: Post?
    var editingIndex: Int?
    private var editingTasks: [Tasks] = []
    private let postsController = PostsController()
    
    @IBOutlet weak var deadlinePicker: UIDatePicker!
    @IBOutlet weak var reminderPicker: UIDatePicker!
    private var reminderWasManuallySet = false

    private var deadlineDate: Date?
    private var reminderDate: Date?
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
    
    
    enum Section: Int, CaseIterable {
        case mainFields
        case deliverables
    }
    
    let mainPlaceholders = [
        "Post Name",
        "Platform",
        "Deadline",
        "Reminder"
    ]
    
    var taskPlaceholders = ["Task 1"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .systemGroupedBackground
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
        
        deadlineDate = deadlinePicker.date
        reminderDate = reminderPicker.date
        
        deadlinePicker.addTarget(self, action: #selector(deadlinePickerChanged), for: .valueChanged)
        reminderPicker.addTarget(self, action: #selector(reminderChanged), for: .valueChanged)
        
        if let post = editingPost {
                    editingTasks = post.tasks

        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tableView.layoutIfNeeded()
        prefillIfNeeded()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setText(_ placeholder: String, value: String) {
        guard let row = mainPlaceholders.firstIndex(of: placeholder) else { return }
        let ip = IndexPath(row: row, section: Section.mainFields.rawValue)
        (tableView.cellForRow(at: ip) as? MainFieldCell)?.textField.text = value
    }
    
    @objc private func deadlinePickerChanged(_ sender: UIDatePicker) {
        deadlineDate = sender.date
        setText("Deadline", value: dateFormatter.string(from: sender.date))
    }

    
    @objc private func reminderChanged() {
        reminderWasManuallySet = true
        reminderDate = reminderPicker.date
        setText("Reminder", value: dateFormatter.string(from: reminderPicker.date))
    }
    
    private func prefillIfNeeded() {
        guard let post = editingPost else { return }

        setText("Post Name", value: post.name)
        setText("Platform", value: post.platform.map { $0.rawValue.capitalized }.joined(separator: ", "))

        if let deadline = post.tasks.first?.deadline {
            deadlineDate = deadline
            setText("Deadline", value: dateFormatter.string(from: deadline))
        }

        if let reminder = post.reminder?.first {
            reminderDate = reminder
            dateFormatter.timeStyle = .short
            setText("Reminder", value: dateFormatter.string(from: reminder))
            dateFormatter.timeStyle = .none
        }

    }
    
//    private func buildPost() -> Post? {
//        
//        guard let deadline = deadlineDate else { return nil }
//        
//        if let reminder = reminderDate,
//           reminderWasManuallySet,
//           reminder >= deadline {
//            return nil
//        }
//
//        
//        let name = getValue("Post Name").isEmpty ? "Untitled Post" : getValue("Post Name")
//        let platformRaw = getValue("Platform")
//        
//        let platforms = platformRaw
//            .split(separator: ",")
//            .map { Platform(rawValue: $0.trimmingCharacters(in: .whitespaces).lowercased()) }
//            .compactMap { $0 }
//        
//        // Deliverables
//        let delIP = IndexPath(row: 0, section: Section.deliverables.rawValue)
//        guard let cell = tableView.cellForRow(at: delIP) as? DeliverableCellAddDeal else {
//            return nil
//        }
//        
//        let tasks = zip(cell.deliverablesText, cell.deliverablesDates).map {
//            title, date in
//            Tasks(
//                id: UUID(),
//                name: title.isEmpty ? "Untitled Task" : title,
//                deadline: date,
//                isCompleted: false
//            )
//        }
//        
//        return Post(
//            id: nil,
//            name: name,
//            platform: platforms,
//            tasks: tasks,
//            reminder: reminderDate != nil ? [reminderDate!] : [],
//            deadline: deadline
//        )
//    }
    
    private func buildPost() -> Post? {

        guard let deadline = deadlineDate else { return nil }

        let postId = editingPost?.id ?? UUID()

        let name = getValue("Post Name").isEmpty
            ? "Untitled Post"
            : getValue("Post Name")

        let platformRaw = getValue("Platform")

        let platforms = platformRaw
            .split(separator: ",")
            .compactMap {
                Platform(rawValue: $0.trimmingCharacters(in: .whitespaces).lowercased())
            }

        let delIP = IndexPath(row: 0, section: Section.deliverables.rawValue)
        guard let cell = tableView.cellForRow(at: delIP) as? DeliverableCellAddDeal else {
            return nil
        }

        let tasks = zip(cell.deliverablesText, cell.deliverablesDates).map { title, date in
            Tasks(
                id: UUID(),
                //post_id: postId,
                name: title.isEmpty ? "Untitled Task" : title,
                deadline: date,
                isCompleted: false
            )
        }

        return Post(
            id: postId,
            name: name,
            platform: platforms,
            tasks: tasks,
            reminder: reminderDate != nil ? [reminderDate!] : [],
            deadline: deadline
        )
    }
    
    @objc private func doneTapped() {
        view.endEditing(true)
        
        Task {
            do {
                guard let post = buildPost() else {
                    print("❌ Failed to build post")
                    return
                }
                
                let savedPost = try await postsController.addPost(post)
                NotificationCenter.default.post(
                    name: .postsDidChange,
                    object: nil
                )
                delegate?.addViewController(self, didCreatePost: savedPost)
                dismiss(animated: true)
                
            } catch {
                print("❌ Failed to insert post:", error)
            }
        }
    }
    
    private func getValue(_ placeholder: String) -> String {
        guard let row = mainPlaceholders.firstIndex(of: placeholder) else { return "" }
        let ip = IndexPath(row: row, section: Section.mainFields.rawValue)
        return (tableView.cellForRow(at: ip) as? MainFieldCell)?.textField.text ?? ""
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sec = Section(rawValue: section) else { return nil }
        switch sec {
        case .mainFields:
            return "Post Details"
        case .deliverables:
            return "Tasks"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sec = Section(rawValue: section) else { return 0 }
        
        switch sec {
        case .mainFields:
            return mainPlaceholders.count
        case .deliverables:
            return 1
        }
    }
    
    override func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let sec = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch sec {
            
        case .mainFields:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "MainFieldCell",
                for: indexPath
            ) as! MainFieldCell
            
            let placeholder = mainPlaceholders[indexPath.row]
            cell.textField.placeholder = placeholder
            
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            toolbar.items = [
                UIBarButtonItem(barButtonSystemItem: .done,
                                target: self,
                                action: #selector(dismissKeyboard))
            ]
            
            switch placeholder {
                
            case "Platform":
                let button = UIButton(type: .system)
                button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
                
                let actions = Platform.allCases.map { platform in
                    UIAction(title: platform.rawValue.capitalized) { _ in
                        cell.textField.text = platform.rawValue.capitalized
                    }
                }
                
                let menu = UIMenu(children: actions)
                button.menu = menu
                button.showsMenuAsPrimaryAction = true
                
                cell.textField.rightView = button
                cell.textField.rightViewMode = .always
                cell.textField.inputView = nil
                cell.textField.inputAccessoryView = toolbar
                
            case "Deadline":
                cell.textField.rightView = nil
                cell.textField.rightViewMode = .never
                let picker = UIDatePicker()
                picker.datePickerMode = .dateAndTime
                picker.preferredDatePickerStyle = .wheels
                picker.addTarget(self, action: #selector(deadlinePickerChanged(_:)), for: .valueChanged)
                cell.textField.inputView = picker
                cell.textField.inputAccessoryView = toolbar

                
            case "Reminder":
                cell.textField.rightView = nil
                cell.textField.rightViewMode = .never
                cell.textField.inputView = reminderPicker
                cell.textField.inputAccessoryView = toolbar
                
            default:
                cell.textField.rightView = nil
                cell.textField.rightViewMode = .never
                cell.textField.inputView = nil
                cell.textField.inputAccessoryView = nil
            }
            
            return cell
            
            
            
        case .deliverables:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "DeliverableCell",
                for: indexPath
            ) as! DeliverableCellAddDeal
            
            cell.delegate = self
            cell.configure(initialPlaceholders: taskPlaceholders)
            cell.placeholderPrefix = "Task"
            cell.addButton.setTitle("+ Task", for: .normal)
            
            return cell
        }
    }
    
    private func parsePlatforms(from raw: String) -> [Platform] {
        raw
            .split(separator: ",")
            .compactMap {
                Platform(rawValue: $0
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased()
                )
            }
    }
    
    func deliverableCellDidTapAdd(_ cell: DeliverableCellAddDeal) {
        let next = taskPlaceholders.count + 1
        let placeholder = "Task \(next)"
        taskPlaceholders.append(placeholder)
        
        cell.addDeliverableField(placeholder: placeholder)
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func deliverableCell(_ cell: DeliverableCellAddDeal, didRemoveAt index: Int) {
        if index < taskPlaceholders.count {
            taskPlaceholders.remove(at: index)
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
