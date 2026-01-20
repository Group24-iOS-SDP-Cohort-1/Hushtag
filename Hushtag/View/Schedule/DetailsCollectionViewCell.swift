//
//  DetailsCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 20/01/26.
//

import UIKit

class DetailsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mainName: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    @IBOutlet weak var remindersLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var deliverableLabel: UILabel!
    @IBOutlet weak var subNameLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    private var currentTask: Task?
    var onToggleCompletion: ((Bool) -> Void)?
    private var isCompleted: Bool = false

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

        deliverableLabel.text = "\(completedCount) / \(totalCount)"
        deliverableLabel.isHidden = false
    }
    
    func configureMultiple(with task: Task) {
        subNameLabel.text = task.name
        if let day = task.deadline.day {
            deadlineLabel.text = abbreviatedDay(from: day)
        } else {
            deadlineLabel.text = "-:—"
        }
        isCompleted = task.isCompleted
        updateCompletionState(isCompleted: isCompleted)
    }

    func configureMultiple(with deliverable: Deliverable) {
        subNameLabel.text = deliverable.name
        if let day = deliverable.deadline.day {
            deadlineLabel.text = abbreviatedDay(from: day)
        } else {
            deadlineLabel.text = "Deadline: —"
        }
        isCompleted = deliverable.isCompleted
        updateCompletionState(isCompleted: isCompleted)
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
    
    private func updateCompletionState(isCompleted: Bool) {
        let symbolName = isCompleted ? "largecircle.fill.circle" : "circle"

        let image = UIImage(
            systemName: symbolName,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        )

        statusButton.setImage(image, for: .normal)
    }
    
    @IBAction func didTapStatusButton(_ sender: UIButton) {
        isCompleted.toggle()
        updateCompletionState(isCompleted: isCompleted)
        onToggleCompletion?(isCompleted)
    }
}
