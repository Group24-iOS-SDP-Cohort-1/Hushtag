//
//  DealsInfo.swift
//  Hushtag
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class DealsInfo: UIViewController {
    var deals : Deal!
    var selectedIdea: Idea?
    
    enum InfoSection: Int, CaseIterable {
        case details
        case deliverables

        var title: String {
            switch self {
            case .details:      return "Details"
            case .deliverables: return "Deliverables"
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = deals.name
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.sectionHeaderTopPadding = 0
        tableView.contentInset.top = 16
        registerCells()

        // Do any additional setup after loading the view.
    }
    
    private func registerCells() {
        tableView.register(UINib(nibName: "DetailFieldCell", bundle: nil),
                           forCellReuseIdentifier: "DetailFieldCell")

       tableView.register(UINib(nibName: "DeliverableCell", bundle: nil),
                          forCellReuseIdentifier: "DeliverableCell")

//        tableView.register(UINib(nibName: "IdeaCardCell", bundle: nil),
//                           forCellReuseIdentifier: "IdeaCardCell")
//
//        tableView.register(UINib(nibName: "NotesCell", bundle: nil),
//                           forCellReuseIdentifier: "NotesCell")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DealsInfo: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return InfoSection.allCases.count   // 2 sections
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {

        guard let sec = InfoSection(rawValue: section) else { return nil }

        let header = UIView()
        //header.backgroundColor = .systemGroupedBackground

        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .black
        label.text = sec.title

        label.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -4)
        ])

        return header
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        return 24
    }

    func tableView(_ tableView: UITableView,
                   viewForFooterInSection section: Int) -> UIView? {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        return spacer
    }
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        guard let sec = InfoSection(rawValue: section) else { return 0 }

        switch sec {
        case .details:
            return 4      // Deadline, Payment, Gmail, Phone
        case .deliverables:
            return deals.deliverable.count
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let sec = InfoSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch sec {

        // SECTION 0: DETAILS
        case .details:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "DetailFieldCell",
                for: indexPath
            ) as! DetailFieldCell

            let rows: [(String, String)] = [
                ("Deadline", overallDeadline()),
                ("Payment", "Rs \(deals.payment)"),
                ("Gmail", deals.email),
                ("Phone number", deals.phone)
            ]
            let item = rows[indexPath.row]
            cell.configure(title: item.0, value: item.1)
            return cell

        // SECTION 1: DELIVERABLES
        case .deliverables:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "DeliverableCell",
                for: indexPath
            ) as! DeliverableCell

            let deliverable = deals.deliverable[indexPath.row]
            cell.configure(with: deliverable)
            return cell
        }
    }
}

extension DealsInfo {
    func overallDeadline() -> String {
        // Example: use last deliverable as final deadline
        guard let last = deals.deliverable.last else { return "-" }
        let day  = last.deadline.day ?? ""
        let date = (last.deadline.date ?? "").prefix(10)
        return "\(day) \(date)"
    }
}
