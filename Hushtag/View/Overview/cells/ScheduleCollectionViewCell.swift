//
//  ScheduleCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class ScheduleCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var completedButton: UIButton!
    weak var delegate: ScheduleCollectionViewCellDelegate?
    private var item: ScheduleItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyLiquidGlassEffect()
    }
    
    func configure(with item: ScheduleItem) {
        self.item = item

        timeLabel.text = "--:--"
        titleLabel.text = ""
        dayLabel.text = ""

        switch item {

        case .post(let post):
            guard let task = post.tasks?.first else { return }

            if let hour = task.deadline.time?.hour,
               let minute = task.deadline.time?.minute {
                timeLabel.text = String(format: "%02d:%02d", hour, minute)
            }

            titleLabel.text = post.name
            dayLabel.text = task.deadline.day
            updateCompletedButton(isCompleted: post.isCompleted)

        case .deal(let deal):
            guard let deliverable = deal.deliverable.first else { return }

            if let hour = deliverable.deadline.time?.hour,
               let minute = deliverable.deadline.time?.minute {
                timeLabel.text = String(format: "%02d:%02d", hour, minute)
            }

            titleLabel.text = deal.name
            dayLabel.text = deliverable.deadline.day
            updateCompletedButton(isCompleted: deal.isCompleted)
        }
    }

    private func updateCompletedButton(isCompleted: Bool) {
        let imageName = isCompleted ? "largecircle.fill.circle" : "circle"
        completedButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.didTapCompleted(item: item)
    }
}

extension Post {
    var isCompleted: Bool {
        guard let tasks = tasks, !tasks.isEmpty else { return false }
        return tasks.allSatisfy { $0.isCompleted }
    }
}

extension Deal {
    var isCompleted: Bool {
        guard !deliverable.isEmpty else { return false }
        return deliverable.allSatisfy { $0.isCompleted }
    }
}

protocol ScheduleCollectionViewCellDelegate: AnyObject {
    func didTapCompleted(item: ScheduleItem?)
}
