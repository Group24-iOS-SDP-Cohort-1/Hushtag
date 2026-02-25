import UIKit

protocol AddDealsDelegate: AnyObject {
    // Call when new deal is created
    func addDealsViewController(_ controller: AddDealsViewController, didCreateDeal deal: Deal)
    func addDealsViewController(_ controller: AddDealsViewController,didUpdateDeal deal: Deal,at index: Int)

}

class AddDealsViewController: UITableViewController, DeliverableCellAddDealDelegate {
    
    weak var delegate: AddDealsDelegate?
    private var deals: [Deal] = []
    var editingDeal: Deal?
    var editingIndex: Int?
    private let dealsController = DealsController()
    private var editingDeliverables: [Deliverable] = []

    @IBOutlet weak var deadlinePicker: UIDatePicker!
    @IBOutlet weak var reminderPicker: UIDatePicker!

    private var deadlineDate: Date?
    private var reminderDate: Date?
    private let dateFormatter = DateFormatter()

    enum Section: Int, CaseIterable {
        case mainFields
        case deliverables
    }
    
    let fieldPlaceholders = [
        "Brand Name",
        "Platform",
        "Payment",
        "Phone number",
        "Email",
        "Deadline",
        "Reminder"
    ]
    
    var deliverablePlaceholders : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .systemGroupedBackground
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        dateFormatter.dateStyle = .medium
        
        deadlinePicker.addTarget(self, action: #selector(deadlineDateChanged), for: .valueChanged)
        reminderPicker.addTarget(self, action: #selector(reminderDateChanged), for: .valueChanged)

        if let deal = editingDeal {
                    editingDeliverables = deal.deliverables

        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tableView.layoutIfNeeded()
        prefillIfNeeded()


    }

    private func prefillIfNeeded() {
        guard let deal = editingDeal else { return }

        setText("Brand Name", value: deal.name)
        setText("Platform", value: deal.platform.map { $0.rawValue.capitalized }.joined(separator: ", "))
        setText("Payment", value: "\(deal.payment)")
        setText("Phone number", value: "\(deal.mobileNumber)")
        setText("Email", value: deal.email)

        if let deadline = deal.deliverables.first?.deadline {
            deadlineDate = deadline
            setText("Deadline", value: dateFormatter.string(from: deadline))
        }

        if let reminder = deal.reminder?.first {
            reminderDate = reminder
            dateFormatter.timeStyle = .short
            setText("Reminder", value: dateFormatter.string(from: reminder))
            dateFormatter.timeStyle = .none
        }

    }
    private func setText(_ placeholder: String, value: String) {
        guard let row = fieldPlaceholders.firstIndex(of: placeholder) else { return }
        let ip = IndexPath(row: row, section: Section.mainFields.rawValue)
        (tableView.cellForRow(at: ip) as? MainFieldCell)?
            .textField.text = value
    }



    @objc func deadlineDateChanged() {
        deadlineDate = deadlinePicker.date
        let indexPath = IndexPath(row: fieldPlaceholders.firstIndex(of: "Deadline")!, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? MainFieldCell {
            cell.textField.text = dateFormatter.string(from: deadlinePicker.date)
        }
    }

    @objc func reminderDateChanged() {
        reminderDate = reminderPicker.date
        let indexPath = IndexPath(row: fieldPlaceholders.firstIndex(of: "Reminder")!, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? MainFieldCell {
            dateFormatter.timeStyle = .short
            cell.textField.text = dateFormatter.string(from: reminderPicker.date)
            dateFormatter.timeStyle = .none
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    @objc private func closeTapped() { dismiss(animated: true) }

    @objc private func doneTapped() {
        print("Done button tapped")

        if let reminderDate = reminderDate, let deadlineDate = deadlineDate, reminderDate >= deadlineDate {
            let alert = UIAlertController(title: "Invalid Reminder", message: "Reminder date must be before the deadline.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        // 1. Read main fields
        var fieldValues: [String] = []
           for row in 0..<fieldPlaceholders.count {
               let ip = IndexPath(row: row, section: Section.mainFields.rawValue)
               let cell = tableView.cellForRow(at: ip) as? MainFieldCell
               fieldValues.append(cell?.textField.text ?? "")
           }

           let brandName   = fieldValues[safe: 0] ?? ""
           let platformRaw = fieldValues[safe: 1] ?? ""
           let payRaw      = fieldValues[safe: 2] ?? ""
           let phone       = fieldValues[safe: 3] ?? ""
           let email       = fieldValues[safe: 4] ?? ""


           // 2. Read deliverables
           let delIP = IndexPath(row: 0, section: Section.deliverables.rawValue)
           guard let delCell = tableView.cellForRow(at: delIP) as? DeliverableCellAddDeal else {
               return
           }

           let texts = delCell.deliverablesText
           let dates = delCell.deliverablesDates
           let deal_id = editingDeal?.id ?? UUID()
           var deliverables: [Deliverable] = []

           for (i, text) in texts.enumerated() {
               let title = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                   ? "Untitled Deliverable"
                   : text

               let deadline = dates[safe: i] ?? Date()

               let old = editingDeal?.deliverables[safe: i]


               deliverables.append(
                   Deliverable(
                       id: UUID(),
                       deal_id: old?.id ?? UUID(),
                       name: title,
                       deadline: deadline,
                       isCompleted: old?.isCompleted ?? false
                   )
               )

           }
//        if deliverables.isEmpty {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateStyle = .medium
//            let deadline = dateFormatter.date(from: deadlineRaw) ?? Date()
//
//            deliverables.append(
//                Deliverable(
//                    id: UUID(),
//                    deal_id: deal_id,
//                    name: "Main Deliverable",
//                    deadline: deadline,
//                    isCompleted: false
//                )
//            )
//        }

           // 3. Parse platform & payment
        let platforms: [Platform] = platformRaw
            .split(separator: ",")
            .compactMap { Platform(rawValue: $0.trimmingCharacters(in: .whitespaces).lowercased()) }


        let sanitizedPay = payRaw
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespaces)

        let paymentValue = Double(sanitizedPay) ?? 0


       
        let newDeal = Deal(
            id: deal_id,
            name: brandName.isEmpty ? "Untitled Brand" : brandName,
            payment: paymentValue,
            mobileNumber: Int64(phone) ?? 0,
            email: email,
            deadline: deadlineDate ?? Date(),
            platform: platforms,
            deliverables: deliverables,
            reminder: reminderDate != nil ? [reminderDate!] : nil
        )

        _Concurrency.Task {
            do {
               
                if let index = editingIndex {
                    let updatedDeal = try await dealsController.updateDeal(newDeal)

                    await MainActor.run {
                        self.delegate?.addDealsViewController(
                            self,
                            didUpdateDeal: updatedDeal,
                            at: index
                        )
                        NotificationCenter.default.post(name: .dealsDidChange, object: nil)
                        self.dismiss(animated: true)
                    }
                }

                else {
                    let savedDeal = try await dealsController.addDeal(newDeal)

                    await MainActor.run {
                        self.delegate?.addDealsViewController(
                            self,
                            didCreateDeal: savedDeal
                        )
                        NotificationCenter.default.post(name: .dealsDidChange, object: nil)
                        self.dismiss(animated: true)
                    }
                }

            } catch {
                print("Failed to save deal:", error)
                let alert = UIAlertController(
                    title: "Error",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }

       }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sec = Section(rawValue: section) else { return nil }
        switch sec {
        case .mainFields:
            return "Deal Details"
        case .deliverables:
            return "Deliverables"
        }
    }


    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {

        return section == Section.mainFields.rawValue
                ? fieldPlaceholders.count
                : 1

    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let sec = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch sec {
        case .mainFields:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "MainFieldCell",
                for: indexPath
            ) as! MainFieldCell
            
            let placeholder = fieldPlaceholders[indexPath.row]
            cell.textField.placeholder = placeholder
            
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPicker))
            toolbar.setItems([doneButton], animated: true)

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
                // cell.textField.isEnabled = false // Optional: prevent typing if strict selection needed
                
            case "Payment":
                cell.textField.rightView = nil
                cell.textField.rightViewMode = .never
                cell.textField.keyboardType = .decimalPad
            case "Phone number":
                cell.textField.rightView = nil
                cell.textField.rightViewMode = .never
                cell.textField.keyboardType = .phonePad
            case "Email":
                cell.textField.rightView = nil
                cell.textField.rightViewMode = .never
                cell.textField.keyboardType = .emailAddress
            case "Deadline":
                cell.textField.rightView = nil
                cell.textField.rightViewMode = .never
                cell.textField.inputView = deadlinePicker
                cell.textField.inputAccessoryView = toolbar
            case "Reminder":
                cell.textField.rightView = nil
                cell.textField.rightViewMode = .never
                cell.textField.inputView = reminderPicker
                cell.textField.inputAccessoryView = toolbar
            default:
                cell.textField.rightView = nil
                cell.textField.rightViewMode = .never
                cell.textField.keyboardType = .default
            }

            return cell
            
        case .deliverables:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "DeliverableCell",
                for: indexPath
            ) as! DeliverableCellAddDeal

            cell.delegate = self
            cell.placeholderPrefix = "Deliverable"
            cell.addButton.setTitle("+ Deliverables", for: .normal)

            // Prefill only when editing
            if !editingDeliverables.isEmpty {
                for d in editingDeliverables {
                    cell.addDeliverableField(placeholder: d.name)
                }
                editingDeliverables.removeAll()
            }

            return cell

        }
    }

    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    
    func deliverableCellDidTapAdd(_ cell: DeliverableCellAddDeal) {
        let nextNumber = deliverablePlaceholders.count + 1
        let placeholder = "Deliverable \(nextNumber)"
        deliverablePlaceholders.append(placeholder)
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        
        cell.addDeliverableField(placeholder: placeholder)
        
        // recalculating the size
        tableView.beginUpdates()
        tableView.endUpdates()
        
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func deliverableCell(_ cell: DeliverableCellAddDeal, didRemoveAt index: Int) {
        // remove placeholder that matches the deleted row (if present)
        if index >= 0 && index < deliverablePlaceholders.count {
            deliverablePlaceholders.remove(at: index)
        }
        
        // recalculating the size
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
