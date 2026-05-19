import UIKit

protocol AddDealsDelegate: AnyObject {
    func addDealsViewController(_ controller: AddDealsViewController, didCreateDeal deal: Deal)
    func addDealsViewController(_ controller: AddDealsViewController, didUpdateDeal deal: Deal, at index: Int)
}

class AddDealsViewController: UITableViewController {
    weak var delegate: AddDealsDelegate?
    private var deals: [Deal] = []
    var editingDeal: Deal?
    var editingIndex: Int?
    private let dealsController = DealsController()
    private var currentDeliverables: [Deliverable] = []

    @IBOutlet var deadlinePicker: UIDatePicker!
    @IBOutlet var reminderPicker: UIDatePicker!

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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .systemGroupedBackground

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: self,
            action: #selector(doneTapped)
        )

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        dateFormatter.dateStyle = .medium

        deadlinePicker.addTarget(self, action: #selector(deadlineDateChanged), for: .valueChanged)
        reminderPicker.addTarget(self, action: #selector(reminderDateChanged), for: .valueChanged)

        if let deal = editingDeal {
            currentDeliverables = deal.deliverables
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

        deadlineDate = deal.deadline
        setText("Deadline", value: dateFormatter.string(from: deal.deadline))

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

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func doneTapped() {
        // print("Done button tapped")

        if let reminderDate = reminderDate, let deadlineDate = deadlineDate, reminderDate >= deadlineDate {
            let alert = UIAlertController(
                title: "Invalid Reminder",
                message: "Reminder date must be before the deadline.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        var fieldValues: [String] = []
        for row in 0 ..< fieldPlaceholders.count {
            let ip = IndexPath(row: row, section: Section.mainFields.rawValue)
            let cell = tableView.cellForRow(at: ip) as? MainFieldCell
            fieldValues.append(cell?.textField.text ?? "")
        }

        let brandName = fieldValues[safe: 0] ?? ""
        let platformRaw = fieldValues[safe: 1] ?? ""
        let payRaw = fieldValues[safe: 2] ?? ""
        let phone = fieldValues[safe: 3] ?? ""
        let email = fieldValues[safe: 4] ?? ""

        let dealId = editingDeal?.id ?? UUID()
        let deliverables = currentDeliverables

        let platforms: [Platform] = platformRaw
            .split(separator: ",")
            .compactMap { Platform(rawValue: $0.trimmingCharacters(in: .whitespaces).lowercased()) }

        let sanitizedPay = payRaw
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespaces)

        let paymentValue = Double(sanitizedPay) ?? 0

        let newDeal = Deal(
            id: dealId,
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
                if editingDeal != nil {
                    let updatedDeal = try await dealsController.updateDeal(newDeal)

                    await MainActor.run {
                        if let index = editingIndex {
                            self.delegate?.addDealsViewController(
                                self,
                                didUpdateDeal: updatedDeal,
                                at: index
                            )
                        }
                        NotificationCenter.default.post(name: .dealsDidChange, object: nil)
                        self.dismiss(animated: true)
                    }
                } else {
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
                // print("Failed to save deal:", error)
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

    override func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    override func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 70
    }

    override func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        return 0.1
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sec = Section(rawValue: section) else { return nil }

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
        headerView.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        if sec == .deliverables {
            titleLabel.text = "Deliverables"

            let addButton = UIButton(type: .system)
            addButton.setTitle("+ Add Deliverable", for: .normal)
            addButton.titleLabel?.font = .systemFont(ofSize: 16)
            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.addTarget(self, action: #selector(addDeliverableTapped), for: .touchUpInside)
            headerView.addSubview(addButton)

            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
                titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12),

                addButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                addButton.lastBaselineAnchor.constraint(equalTo: titleLabel.lastBaselineAnchor)
            ])

            return headerView
        }

        if sec == .mainFields {
            titleLabel.text = "Deal Details"

            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 32),
                titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12)
            ])

            return headerView
        }

        return nil
    }

    override func tableView(_: UITableView, titleForHeaderInSection _: Int) -> String? {
        return nil
    }

    @objc private func addDeliverableTapped() {
        let newDeliverable = Deliverable(
            id: UUID(),
            dealId: editingDeal?.id ?? UUID(),
            name: "",
            deadline: Date(),
            isCompleted: false
        )
        currentDeliverables.append(newDeliverable)

        let indexPath = IndexPath(row: currentDeliverables.count - 1, section: Section.deliverables.rawValue)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.section == Section.deliverables.rawValue, editingStyle == .delete {
            currentDeliverables.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    override func tableView(
        _: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return section == Section.mainFields.rawValue
            ? fieldPlaceholders.count
            : currentDeliverables.count
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
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: "MainFieldCell", for: indexPath) as? MainFieldCell
            else {
                return UITableViewCell()
            }

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
            guard let cell = tableView
                .dequeueReusableCell(withIdentifier: "DynamicItemCell", for: indexPath) as? DynamicItemCell
            else {
                return UITableViewCell()
            }

            let deliverable = currentDeliverables[indexPath.row]
            cell.configure(title: deliverable.name, placeholder: "Deliverable title", date: deliverable.deadline)

            cell.titleChanged = { [weak self] newTitle in
                self?.currentDeliverables[indexPath.row].name = newTitle
            }

            cell.dateChanged = { [weak self] newDate in
                self?.currentDeliverables[indexPath.row].deadline = newDate
            }

            return cell
        }
    }

    @objc func dismissPicker() {
        view.endEditing(true)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
