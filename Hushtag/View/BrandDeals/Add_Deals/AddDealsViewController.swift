import UIKit

protocol AddDealsDelegate: AnyObject {
    // Call when new deal is created
    func addDealsViewController(_ controller: AddDealsViewController, didCreateDeal deal: Deal)
}

class AddDealsViewController: UITableViewController, DeliverableCellAddDealDelegate {
    
    weak var delegate: AddDealsDelegate?
   // var InputDeal : Deal?
    private var deals: [Deal] = []

    private let dealsController = DealsController()


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
    
    var deliverablePlaceholders : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
        
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(closeTapped)
        
        navigationItem.rightBarButtonItem?.target = self
        navigationItem.rightBarButtonItem?.action = #selector(doneTapped)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    @objc private func closeTapped() { dismiss(animated: true) }

    @objc private func doneTapped() {
        
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
           let description = fieldValues[safe: 5] ?? ""

           // 2. Read deliverables
           let delIP = IndexPath(row: 0, section: Section.deliverables.rawValue)
           guard let delCell = tableView.cellForRow(at: delIP) as? DeliverableCellAddDeal else {
               return
           }

           let texts = delCell.deliverablesText
           let dates = delCell.deliverablesDates

           var deliverables: [Deliverable] = []

           for (i, text) in texts.enumerated() {
               let title = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                   ? "Untitled Deliverable"
                   : text

               let deadline = dates[safe: i] ?? Date()

               deliverables.append(
                   Deliverable(
                       name: title,
                       deadline: deadline,
                       isCompleted: false
                   )
               )
           }

           // 3. Parse platform & payment
           let platforms = platformRaw.isEmpty
               ? []
               : platformRaw.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

           let sanitizedPay = payRaw
               .replacingOccurrences(of: ",", with: "")
               .trimmingCharacters(in: .whitespaces)

           let paymentValue = Int(sanitizedPay) ?? 0

       
           let newDeal = Deal(
               id: UUID(),
               name: brandName.isEmpty ? "Untitled Brand" : brandName,
               deliverables: deliverables,
               platform: platforms,
               phone: phone,
               email: email,
               description: description,
               payment: paymentValue
           )


        _Concurrency.Task {
               do {
                   let savedDeal = try await dealsController.addDeal(newDeal)

                   await MainActor.run {
                       self.delegate?.addDealsViewController(
                           self,
                           didCreateDeal: savedDeal
                       )
                       self.dismiss(animated: true)
                   }
               } catch {
                   print("❌ Failed to add deal:", error)
               }
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
            cell.placeholderPrefix = "Deliverable"
            cell.addButton.setTitle("+ Deliverables", for: .normal)
            return cell
        }
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
