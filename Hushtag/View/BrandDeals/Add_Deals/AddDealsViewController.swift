import UIKit

protocol AddDealsDelegate: AnyObject {
    /// Called when AddDealsViewController has created a new deal
    func addDealsViewController(_ controller: AddDealsViewController, didCreateDeal deal: Deal)
}

class AddDealsViewController: UITableViewController, DeliverableCellAddDealDelegate {

    weak var delegate: AddDealsDelegate?
    var InputDeal : Deal?

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
        "Description"
    ]

    // Start with 2 deliverable fields (you asked to show 2)
    var deliverablePlaceholders = [
        "Deliverable 1",
        "Deliverable 2"
    ]

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

        // Map fields (ensure indexes match placeholders array)
        let brandName   = fieldValues.safe(0) ?? ""
        let platformRaw = fieldValues.safe(1) ?? ""
        let payRaw      = fieldValues.safe(2) ?? ""
        let phone       = fieldValues.safe(3) ?? ""
        let email       = fieldValues.safe(4) ?? ""
        let description = fieldValues.safe(5) ?? ""

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
            let title = t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled Deliverable" : t
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

        // parse payment safely (remove commas/spaces)
        let sanitizedPay = payRaw.replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespaces)
        let paymentValue = Int(sanitizedPay) ?? 0

        let deal = Deal(
            name: brandName.isEmpty ? "Untitled Brand" : brandName,
            deliverable: deliverables,
            platform: platforms,
            phone: phone,
            email: email,
            description: description,
            payment: paymentValue,
            selectedIdeaIndex: nil
        )

        // save locally
        self.InputDeal = deal

        // 1) Inform delegate (preferred)
        delegate?.addDealsViewController(self, didCreateDeal: deal)

        // 2) Also dismiss self (presenting VC or flow may append as well)
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
            return fieldPlaceholders.count
        case .deliverables:
            return 1
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

    func deliverableCell(_ cell: DeliverableCellAddDeal, didRemoveAt index: Int) {
        // remove placeholder that matches the deleted row (if present)
        if index >= 0 && index < deliverablePlaceholders.count {
            deliverablePlaceholders.remove(at: index)
        }

        // force table to recalc sizing for that row
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

// MARK: - Safe array subscript helper
extension Array {
    func safe(_ index: Int) -> Element? {
        return (index >= 0 && index < count) ? self[index] : nil
    }
}
