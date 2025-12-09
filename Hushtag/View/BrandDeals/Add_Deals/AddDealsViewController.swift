import UIKit

class AddDealsViewController: UITableViewController, DeliverableCellAddDealDelegate {

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

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add deals"

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56

        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(closeTapped)

        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = #selector(doneTapped)
    }

    @objc private func closeTapped() { dismiss(animated: true) }
    @objc private func doneTapped()  { dismiss(animated: true) }

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
}
