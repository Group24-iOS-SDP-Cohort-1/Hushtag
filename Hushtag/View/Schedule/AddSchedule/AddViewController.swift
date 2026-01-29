import UIKit


//sending the create post to parent view controller
protocol AddViewDelegate: AnyObject {
    func addViewController(_ controller: AddViewController, didCreatePost post: Post)
}

class AddViewController: UITableViewController, DeliverableCellAddDealDelegate {
    
    weak var delegate: AddViewDelegate?  // hold reference to parent view controller
    var hasSelectedReminder = false
    private let postsController = PostsController()
    private var reminderOffset: DateComponents?
    
    enum Section: Int, CaseIterable {
        case mainFields
        case reminder
        case deliverables
    }
    private let hourRange = Array(0...23)
    private let minuteRange = stride(from: 0, through: 55, by: 5).map { $0 }
    
    let mainPlaceholders = [
        "Post Name",
        "Platform",
    ]
    
    var taskPlaceholders = ["Task 1"]
    
    var reminderText: String = "1 hour before"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        
        var values: [String] = []
        
        for row in 0..<mainPlaceholders.count {
            let indexPath = IndexPath(row: row, section: Section.mainFields.rawValue)
            let cell = tableView.cellForRow(at: indexPath) as? MainFieldCell
            values.append(cell?.textField.text ?? "")
        }
        
        let postName = values.first?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty == false
        ? values.first!.trimmingCharacters(in: .whitespacesAndNewlines)
        : "Untitled Post"
        
        let platformRaw = values.count > 1 ? values[1] : ""
        let platforms = parsePlatforms(from: platformRaw)
        
        
        let deliverableIndexPath = IndexPath(row: 0, section: Section.deliverables.rawValue)
        
        guard let deliverableCell = tableView.cellForRow(at: deliverableIndexPath)
                as? DeliverableCellAddDeal else {
            dismiss(animated: true)
            return
        }
        
        let taskTitles = deliverableCell.deliverablesText
        let taskDates = deliverableCell.deliverablesDates
        
        var tasks: [Tasks] = []
        
        for (index, rawTitle) in taskTitles.enumerated() {
            
            let title = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            if title.isEmpty { continue }
            
            guard let deadline = taskDates[safe: index] as? Date else { continue }
            
            tasks.append(
                Tasks(
                    id: UUID(),
                    name: title,
                    deadline: deadline,
                    isCompleted: false
                )
            )
        }
        
        let reminders: [Date]
        
        if let offset = reminderOffset {
            let calendar = Calendar.current
            reminders = tasks.compactMap { task in
                calendar.date(byAdding: offset, to: task.deadline)
            }
        } else {
            reminders = []
        }
        
        let post = Post(
            id: UUID(),
            name: postName,
            platform: platforms,
            tasks: tasks,
            reminder: reminders
        )
        
        
        
        DataStore.shared.savePost(post)
        delegate?.addViewController(self, didCreatePost: post)
        dismiss(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sec = Section(rawValue: section) else { return 0 }
        
        switch sec {
        case .mainFields:
            return mainPlaceholders.count
        case .reminder:
            return 1
        case .deliverables:
            return 1
        }
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard let sec = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch sec {
            
        case .mainFields:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "MainFieldCell",
                for: indexPath
            ) as! MainFieldCell
            
            cell.textField.placeholder = mainPlaceholders[indexPath.row]
            return cell
            
        case .reminder:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "MainFieldCell",
                for: indexPath
            ) as! MainFieldCell
            
            cell.textField.isUserInteractionEnabled = false
            
            if hasSelectedReminder {
                // User has selected a reminder
                cell.textField.text = reminderText
                cell.textField.textColor = .label
                cell.textField.placeholder = nil
            } else {
                // Initial placeholder state
                cell.textField.text = nil
                cell.textField.placeholder = "Reminder"
                cell.textField.textColor = .secondaryLabel
            }
            
            let chevron = UIImageView(image: UIImage(systemName: "chevron.down"))
            chevron.tintColor = .secondaryLabel
            chevron.contentMode = .scaleAspectFit
            chevron.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
            
            cell.textField.rightView = chevron
            cell.textField.rightViewMode = .always
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard Section(rawValue: indexPath.section) == .reminder else { return }
        showReminderSheet()
    }
    private func showReminderSheet() {
        let alert = UIAlertController(
            title: "Reminder",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "1 Hour Before", style: .default) { _ in
            self.setReminder(hour: 1, minute: 0)
        })
        
        alert.addAction(UIAlertAction(title: "2 Hours Before", style: .default) { _ in
            self.setReminder(hour: 2, minute: 0)
        })
        
        alert.addAction(UIAlertAction(title: "Custom", style: .default) { _ in
            self.showCustomReminderPicker()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    private func showCustomReminderPicker() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250, height: 200)
        
        let picker = UIPickerView()
        picker.frame = CGRect(x: 0, y: 0, width: 250, height: 200)
        picker.dataSource = self
        picker.delegate = self
        
        vc.view.addSubview(picker)
        
        let alert = UIAlertController(
            title: "Custom Reminder",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.setValue(vc, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            let hour = self.hourRange[picker.selectedRow(inComponent: 0)]
            let minute = self.minuteRange[picker.selectedRow(inComponent: 1)]
            self.setReminder(hour: hour, minute: minute)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func setReminder(hour: Int, minute: Int) {
        hasSelectedReminder = true
        
        reminderOffset = DateComponents(hour: -hour, minute: -minute)
        
        if hour > 0 && minute == 0 {
            reminderText = "\(hour) hour before"
        } else {
            reminderText = "\(hour)h \(minute)m before"
        }
        
        let ip = IndexPath(row: 0, section: Section.reminder.rawValue)
        tableView.reloadRows(at: [ip], with: .none)
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
extension AddViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? hourRange.count : minuteRange.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0
        ? "\(hourRange[row]) h"
        : "\(minuteRange[row]) m"
    }
}
