import UIKit

protocol AddDealsDelegate: AnyObject {
    /// Called when AddDealsViewController has created a new deal
    func addDealsViewController(_ controller: AddDealsViewController, didCreateDeal deal: Deal)
}

class AddDealsViewController: UITableViewController, DeliverableCellAddDealDelegate, UITextFieldDelegate {
    weak var delegate: AddDealsDelegate?
    var InputDeal : Deal?
    
    enum Section: Int, CaseIterable {
        case mainFields
        case deliverables
    }

    let fieldPlaceholders = [
        "Brand Name",
        "Deadline",
        "Platform",
        "Phone number",
        "Email",
        "Description"
    ]

    // Start with 3 deliverable fields
    var deliverablePlaceholders = [
        "Deliverable 1",
        "Deliverable 2",
        "Deliverable 3"
    ]

    // ----- NEW: store deadline selection for the main "Deadline" field -----
    private var deadlineDate: Date?
    private let mainDeadlineFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd MMM, h:mm a"
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56

        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(closeTapped)

        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = #selector(doneTapped)
    }

    @objc private func closeTapped() { dismiss(animated: true) }

    @objc private func doneTapped() {
        // 1) read main fields (Brand name etc)
        var fieldValues: [String] = []
        for row in 0..<fieldPlaceholders.count {
            let ip = IndexPath(row: row, section: Section.mainFields.rawValue)
            let cell = tableView.cellForRow(at: ip) as? MainFieldCell
            fieldValues.append(cell?.textField.text ?? "")
        }

        let brandName   = fieldValues[0]
        let platformRaw = fieldValues[2]
        let phone       = fieldValues[3]
        let email       = fieldValues[4]
        let description = fieldValues[5]

        // 2) read deliverable cell
        let delIP = IndexPath(row: 0, section: Section.deliverables.rawValue)
        guard let delCell = tableView.cellForRow(at: delIP) as? DeliverableCellAddDeal else {
            dismiss(animated: true); return
        }

        let texts = delCell.deliverablesText
        let dates = delCell.deliverablesDates

        // 3) map into your model
        var deliverables: [Deliverable] = []
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        let dayFormatter = DateFormatter(); dayFormatter.dateFormat = "EEEE"
        let cal = Calendar.current

        for (i, t) in texts.enumerated() {
            let title = t.isEmpty ? "Untitled Deliverable" : t
            if let d = dates.safe(i) ?? nil {
                let day = dayFormatter.string(from: d)
                let iso = isoFormatter.string(from: d)
                let comps = cal.dateComponents([.hour, .minute], from: d)
                let deadline = Deadline(day: day, date: iso, time: Time(hour: comps.hour, minute: comps.minute))
                let item = Deliverable(name: title, deadline: deadline, isCompleted: false)
                deliverables.append(item)
            } else {
                let deadline = Deadline(day: nil, date: nil, time: nil)
                let item = Deliverable(name: title, deadline: deadline, isCompleted: false)
                deliverables.append(item)
            }
        }

        // 4) build Deal (keep missing fields simple)
        let platforms = platformRaw.isEmpty ? [] : platformRaw.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        // Optionally include the main deadline if you want to store it in the model:
        // Here we ignore it for the Deal structure since your Deal has deliverable deadlines.
        // If you want to store an overall deal deadline, create a Deadline from deadlineDate (example below).
        let deal = Deal(
            name: brandName.isEmpty ? "Untitled Brand" : brandName,
            deliverable: deliverables,
            platform: platforms,
            phone: phone,
            email: email,
            description: description,
            payment: 0,
            selectedIdeaIndex: nil
        )

            self.InputDeal = deal
            delegate?.addDealsViewController(self, didCreateDeal: deal)
            dismiss(animated: true)
    }

    // MARK: - TableView DataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count   // 2 sections
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        guard let sec = Section(rawValue: section) else { return 0 }
        switch sec {
        case .mainFields:
            return fieldPlaceholders.count     // 6 fields
        case .deliverables:
            return 1                           // single card cell
        }
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

            // If this is the "Deadline" field, add calendar button and wire it
            if placeholder == "Deadline" {
                // create calendar button if not already set
                if cell.textField.rightView == nil {
                    let btn = UIButton(type: .system)
                    btn.setImage(UIImage(systemName: "calendar"), for: .normal)
                    btn.tintColor = .systemGray
                    btn.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
                    btn.addTarget(self, action: #selector(deadlineButtonTapped(_:)), for: .touchUpInside)
                    cell.textField.rightViewMode = .always
                    cell.textField.rightView = btn
                    // prevent keyboard if user taps the text field (optional)
                    cell.textField.delegate = self
                }

                // show current selection text if present
                if let d = deadlineDate {
                    cell.textField.text = mainDeadlineFormatter.string(from: d)
                    cell.textField.textColor = .label
                } else {
                    // leave text empty so placeholder shows
                    cell.textField.text = ""
                }
            } else {
                // ensure no right view for other fields
                cell.textField.rightView = nil
                cell.textField.delegate = nil
            }

            return cell

        case .deliverables:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "DeliverableCell",
                for: indexPath
            ) as! DeliverableCellAddDeal

            cell.delegate = self
            cell.configure(initialPlaceholders: deliverablePlaceholders)
            return cell
        }
    }

    // MARK: - DeliverableCellAddDealDelegate

    func deliverableCellDidTapAdd(_ cell: DeliverableCellAddDeal) {
        let nextNumber = deliverablePlaceholders.count + 1
        let placeholder = "Deliverable \(nextNumber)"
        deliverablePlaceholders.append(placeholder)

        guard let indexPath = tableView.indexPath(for: cell) else { return }

        // 1) Update the cell’s stack
        cell.addDeliverableField(placeholder: placeholder)

        // 2) Ask the table to recalc that row height and its contentSize
        tableView.beginUpdates()
        tableView.endUpdates()

        // 3) Optionally scroll so the new field is visible
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    // handle delete request from cell
    func deliverableCell(_ cell: DeliverableCellAddDeal, didRemoveAt index: Int) {
        // remove placeholder that matches the deleted row (if present)
        if index >= 0 && index < deliverablePlaceholders.count {
            deliverablePlaceholders.remove(at: index)
        }

        // force table to recalc sizing for that row
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    // MARK: - Deadline picker wiring

    @objc private func deadlineButtonTapped(_ sender: UIButton) {
        showDeadlinePicker(sourceView: sender)
    }

    private func showDeadlinePicker(sourceView: UIView) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        if let d = deadlineDate { datePicker.date = d }

        // wrap in content VC
        let contentVC = UIViewController()
        contentVC.view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        let minWidth: CGFloat = 320
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: contentVC.view.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: contentVC.view.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: contentVC.view.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: contentVC.view.bottomAnchor),
            datePicker.widthAnchor.constraint(greaterThanOrEqualToConstant: minWidth),
            contentVC.view.widthAnchor.constraint(greaterThanOrEqualToConstant: minWidth)
        ])
        contentVC.preferredContentSize = CGSize(width: minWidth, height: 340)

        let alert = UIAlertController(title: "Select date & time", message: nil, preferredStyle: .actionSheet)
        alert.setValue(contentVC, forKey: "contentViewController")

        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let selected = datePicker.date
            self.deadlineDate = selected

            // update the Deadline text field at row 1
            let ip = IndexPath(row: 1, section: Section.mainFields.rawValue)
            if let cell = self.tableView.cellForRow(at: ip) as? MainFieldCell {
                cell.textField.text = self.mainDeadlineFormatter.string(from: selected)
                cell.textField.textColor = .label
            }
            if let btn = sourceView as? UIButton {
                    btn.tintColor = UIColor(red: 139/255, green: 92/255, blue: 246/255, alpha: 1)
                }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // iPad popover configuration & present
        // Use navigationController if available, otherwise use self
        let presenter = self.navigationController ?? self

        if let pop = alert.popoverPresentationController {
            pop.sourceView = sourceView
            pop.sourceRect = sourceView.bounds
            pop.permittedArrowDirections = [.up, .down]
            // if you want a fallback rect:
            if sourceView.bounds == .zero {
                pop.sourceRect = presenter.view.bounds
            }
        }

        // ensure presentation happens on main thread
        DispatchQueue.main.async {
            presenter.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - UITextFieldDelegate (optional: intercept taps on Deadline text field)

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // If the textField is the Deadline field, open the picker and prevent keyboard
        // We can identify by placeholder text (Deadline) or by walking to the cell.
        if textField.placeholder == "Deadline" {
            // present picker anchored to the text field
            showDeadlinePicker(sourceView: textField)
            return false
        }
        return true
    }
}

extension Array {
    func safe(_ index: Int) -> Element? {
        return (index >= 0 && index < count) ? self[index] : nil
    }
}
