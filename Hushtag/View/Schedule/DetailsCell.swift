//
//  DetailsCell.swift
//  Hushtag
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit

class DetailsCell: UICollectionViewCell {
    
    @IBOutlet weak var mainName: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    @IBOutlet weak var remindersLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var subNameLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configureCommon(with item: ScheduleItem) {
        
        // Reset / hide everything first
        [
            platformLabel,
            remindersLabel
        ].forEach {
            $0?.text = nil
            $0?.isHidden = true
        }
        
        switch item {
        case .post(let post):
            
            mainName.text = post.name
            if !post.platform.isEmpty {
                platformLabel.text = "Platform: " + post.platform.joined(separator: ", ")
                platformLabel.isHidden = false
            }
            if !post.reminder.isEmpty {
                remindersLabel.text = post.reminder.joined(separator: ", ")
                remindersLabel.isHidden = false
            }
           
        case .deal(let deal):
            
            mainName.text = deal.name

            platformLabel.text = "Platform: " + deal.platform.joined(separator: ", ")
            platformLabel.isHidden = false
        }
    }
    
    func DealDetails(with deal: Deal) {
        
        let completedCount = deal.deliverable.filter { $0.isCompleted }.count
        let totalCount = deal.deliverable.count

        paymentLabel.text = "\(deal.payment)"
        paymentLabel.isHidden = false

        phoneLabel.text = deal.phone
        phoneLabel.isHidden = false

        emailLabel.text = deal.email
        emailLabel.isHidden = false

        descriptionLabel.text = "\(completedCount) / \(totalCount)"
        descriptionLabel.isHidden = false
    }
    
    func configureMultiple(with task: Task) {
        subNameLabel.text = task.name
        if let day = task.deadline.day {
            deadlineLabel.text = abbreviatedDay(from: day)
        } else {
            deadlineLabel.text = "-:—"
        }

    }

    func configureMultiple(with deliverable: Deliverable) {
        subNameLabel.text = deliverable.name
        if let day = deliverable.deadline.day {
            deadlineLabel.text = abbreviatedDay(from: day)
        } else {
            deadlineLabel.text = "Deadline: —"
        }
    }
    
    private func abbreviatedDay(from day: String) -> String {
        let map: [String: String] = [
            "Monday": "Mon",
            "Tuesday": "Tue",
            "Wednesday": "Wed",
            "Thursday": "Thu",
            "Friday": "Fri",
            "Saturday": "Sat",
            "Sunday": "Sun"
        ]
        return map[day] ?? day.prefix(3).capitalized
    }
}
