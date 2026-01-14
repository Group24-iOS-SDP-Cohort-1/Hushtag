//
//  AddViewController.swift
//  Hushtag
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

protocol AddViewControllerDelegate: AnyObject {
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
        
        // commented out deals — left as is
        case "Posts":
            let name = textValues[0]
            let postingDate = dateValues[1]
            let platformText = textValues[2]
            let remindersText = textValues[4]

            guard let postingDate else { return }

            // Platform array
            let platformArray = platformText.isEmpty
                ? []
                : platformText
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) }

            // Reminder array
            let remindersArray = remindersText.isEmpty
                ? []
                : remindersText
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) }

            // Create ONE task for the post
            let task = Task(
                name: "Publish Post",
                deadline: convertToDateData(postingDate),
                isCompleted: false
            )

            let newPost = Post(
                name: name,
                platform: platformArray,
                tasks: [task],
                reminder: remindersArray
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
