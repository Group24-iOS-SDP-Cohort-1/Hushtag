import UIKit


//sending the create post to parent view controller
protocol AddViewDelegate: AnyObject {
    func addViewController(_ controller: AddViewController, didCreatePost post: Post)
    func addViewController(_ controller: AddViewController, didUpdatePost post: Post,at index: Int)
}

class AddViewController: UITableViewController {
    
    weak var delegate: AddViewDelegate?
    var editingPost: Post?
    var editingIndex: Int?
    private var currentTasks: [Tasks] = []
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
            currentTasks = post.tasks
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

        let tasks = currentTasks

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

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sec = Section(rawValue: section) else { return nil }
        
        if sec == .deliverables {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
            headerView.backgroundColor = .clear
            
            let titleLabel = UILabel()
            titleLabel.text = "Tasks"
            titleLabel.font = .systemFont(ofSize: 13, weight: .regular)
            titleLabel.textColor = .secondaryLabel
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(titleLabel)
            
            let addButton = UIButton(type: .system)
            addButton.setTitle("+ Add Task", for: .normal)
            addButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.addTarget(self, action: #selector(addTaskTapped), for: .touchUpInside)
            headerView.addSubview(addButton)
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
                
                addButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                addButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
            ])
            
            return headerView
        }
        
        let label = UILabel()
        label.text = "Post Details"
        return nil
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sec = Section(rawValue: section) else { return nil }
        if sec == .mainFields {
            return "Post Details"
        }
        return nil
    }

    @objc private func addTaskTapped() {
        let newTask = Tasks(id: UUID(), name: "", deadline: Date(), isCompleted: false)
        currentTasks.append(newTask)
        
        let indexPath = IndexPath(row: currentTasks.count - 1, section: Section.deliverables.rawValue)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == Section.deliverables.rawValue, editingStyle == .delete {
            currentTasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sec = Section(rawValue: section) else { return 0 }
        
        switch sec {
        case .mainFields:
            return mainPlaceholders.count
        case .deliverables:
            return currentTasks.count
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
                withIdentifier: "DynamicItemCell",
                for: indexPath
            ) as! DynamicItemCell
            
            let task = currentTasks[indexPath.row]
            cell.configure(title: task.name, placeholder: "Task title", date: task.deadline)
            
            cell.titleChanged = { [weak self] newTitle in
                self?.currentTasks[indexPath.row].name = newTitle
            }
            
            cell.dateChanged = { [weak self] newDate in
                self?.currentTasks[indexPath.row].deadline = newDate
            }
            
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
}
