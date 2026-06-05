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
    var currentDeliverables: [Deliverable] = []

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
        let indexPath = IndexPath(row: row, section: Section.mainFields.rawValue)
        (tableView.cellForRow(at: indexPath) as? MainFieldCell)?
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

        let newDeal = createDealFromFields()
        saveDeal(newDeal)
    }

    private func createDealFromFields() -> Deal {
        var fieldValues: [String] = []
        for row in 0 ..< fieldPlaceholders.count {
            let indexPath = IndexPath(row: row, section: Section.mainFields.rawValue)
            let cell = tableView.cellForRow(at: indexPath) as? MainFieldCell
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

        return Deal(
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
    }

    private func saveDeal(_ newDeal: Deal) {
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

    // MARK: - TableView delegate and datasource methods moved to AddDealsViewController+TableView.swift

    @objc func addDeliverableTapped() {
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

    @objc func dismissPicker() {
        view.endEditing(true)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
