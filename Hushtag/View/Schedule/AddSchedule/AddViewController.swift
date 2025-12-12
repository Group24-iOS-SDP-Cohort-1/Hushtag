//
//  AddViewController.swift
//  Hushtag
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

protocol AddViewControllerDelegate: AnyObject {
    func addViewController(_ controller: AddViewController, didAddTask task: Task)
    func addViewController(_ controller: AddViewController, didAddDeal deal: Deal)
    func addViewController(_ controller: AddViewController, didAddPost post: Post)
}

class AddViewController: UIViewController {
    @IBOutlet weak var fieldView: UITableView!
    
    weak var delegate: AddViewControllerDelegate?

    var category: String?
    var post: [Post]?
    var deals: [Deal]?
    var tasks: [Task]?
    private var textValues: [String] = Array(repeating: "", count: 5)
    private var dateValues: [Date?] = Array(repeating: nil, count: 5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fieldView.delegate = self
        fieldView.dataSource = self
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        view.endEditing(true)

            
            if textValues[0].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let alert = UIAlertController(title: "Missing name", message: "Please enter a name.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }
            saveTapped()
    }
    
    func convertToDateData(_ date: Date) -> DateData {
        let calendar = Calendar.current

        // Extract hour + minute
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)

        // Extract day string (Mon, Tue, ...)
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        let dayString = dayFormatter.string(from: date)

        // Extract short date string (10 Dec 2025)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let dateString = dateFormatter.string(from: date)

        let time = TimeData(hour: hour, minute: minute)

        return DateData(day: dayString, date: dateString, time: time)
    }
    
    @objc func cancelTapped() {
            dismiss(animated: true, completion: nil)
        }

    @objc func saveTapped() {
        guard let category = category else { return }

        // Make sure any editing is committed
        view.endEditing(true)

        switch category {
        case "Tasks":
            let name = textValues[0]
            let start = dateValues[1]
            let end = dateValues[2]
            let description = textValues[3]
            let remindersString = textValues[4]

            let startDateData = start.map { convertToDateData($0) }
            let endDateData = end.map { convertToDateData($0) }

            let emptyDate = DateData(day: "", date: "", time: TimeData(hour: 0, minute: 0))

            let remindersArray = remindersString.isEmpty
                ? []
                : remindersString
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) }

            // if your Task model accepts optional dates you can pass startDateData / endDateData directly.
            // Here we pass non-optional DateData by falling back to emptyDate (you can change if model is optional)
            let newTask = Task(
                name: name,
                startDate: startDateData ?? emptyDate,
                endDate: endDateData ?? emptyDate,
                description: description,
                reminder: remindersArray,
                isCompleted: false
            )
            delegate?.addViewController(self, didAddTask: newTask)

        // commented out deals — left as is
        case "Posts":
            let name = textValues[0]
            let postingTime = dateValues[1]
            let platform = textValues[2]
            let description = textValues[3]
            let reminders = textValues[4]

            let postTime = postingTime.map { convertToDateData($0) }
            let emptyDate = DateData(day: "", date: "", time: TimeData(hour: 0, minute: 0))

            let remindersArray = reminders.isEmpty
                ? []
                : reminders
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) }

            let platformArray = platform.isEmpty
                ? []
                : platform
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) }

            let newPost = Post(
                name: name,
                postingTime: postTime ?? emptyDate,
                platform: platformArray,
                description: description,
                reminder: remindersArray,
                isCompleted: false
            )
            delegate?.addViewController(self, didAddPost: newPost)

        default:
            break
        }

        // Dismiss once after building + sending model
        dismiss(animated: true, completion: nil)
    }
}
    


extension AddViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fieldCell", for: indexPath) as! FieldTableViewCell
        
        let initialText = textValues[indexPath.row]
        let initialDate = dateValues[indexPath.row]
        
        cell.configure(index: indexPath.row, category: category ?? "", initialText: initialText, initialDate: initialDate)
        
        cell.textField.isUserInteractionEnabled = true
        cell.textField.isEnabled = true
        
        cell.onTextChanged = { [weak self] newText in
                    guard let self = self else { return }
                    self.textValues[indexPath.row] = newText
                }
        
        cell.onDateChanged = { [weak self] newDate in
                    guard let self = self else { return }
                    self.dateValues[indexPath.row] = newDate
                }
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "goToAddStuff", sender: indexPath.row)
        
        tableView.deselectRow(at: indexPath, animated: true)

            guard let cell = tableView.cellForRow(at: indexPath) as? FieldTableViewCell else { return }

            // If this row uses a textField, focus it. If datePicker row, show date-picker or do nothing.
            if !cell.textField.isHidden {
                cell.textField.becomeFirstResponder()
            } else {
                // If the cell shows a date picker instead, toggle visibility or open a date editor if desired.
                // e.g. show a custom date picker modal or animate in-place picker.
            }
    }

}
