//
//  DetailsTableViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class DetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    let values = [
        ["Name", "Deliverables", "Platform", "Phone", "Email"],
        ["Name", "Posting Time", "Platform", "Tasks", "Reminder(s)"]
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func formatDate(_ dateData: DateData?) -> String {
        guard
            let d = dateData,
            let dateString = d.date,
            let day = d.day,
            let time = d.time,
            let hour = time.hour,
            let minute = time.minute
        else {
            return "--"
        }

        let timeString = String(format: "%02d:%02d", hour, minute)

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]

        guard let date = isoFormatter.date(from: dateString) else {
            return "\(timeString), \(day)"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d"

        let monthDay = formatter.string(from: date)
        return "\(timeString), \(monthDay), \(day)"
    }

    
    func stringFromArray(_ array: [String]?) -> String {
        return array?.joined(separator: ", ") ?? ""
    }

    func configure(task: Task?, deal: Deal?, post: Post?, index: Int) {

        // Left-side label
        if deal != nil {
            descriptionLabel.text = values[0][index]
        } else {
            descriptionLabel.text = values[1][index]
        }

        var value = ""

        if let deal = deal {

            let deliverables = deal.deliverable
                .map { $0.name }
                .joined(separator: ", ")

            let rows: [String] = [
                deal.name,
                deliverables,
                stringFromArray(deal.platform),
                deal.phone,
                deal.email
            ]

            value = rows[index]
        }

        else if let post = post {

            let postingDate = post.tasks?.first?.deadline

            let tasksString = post.tasks?
                .map { $0.name }
                .joined(separator: ", ") ?? "--"

            let rows: [String] = [
                post.name,
                formatDate(postingDate),
                stringFromArray(post.platform),
                tasksString,
                stringFromArray(post.reminder)
            ]

            value = rows[index]
        }

        valueLabel.numberOfLines = (index == 1 || index == 3) ? 0 : 1
        valueLabel.text = value
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
