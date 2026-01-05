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
    @IBOutlet weak var platformLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        applyLiquidGlassEffect()
    }
    func configureCell(_ post: Post?, _ deal: Deal?, _ task: Task?) {
        timeLabel.text = "--:--"
        titleLabel.text = ""
        dayLabel.text = ""
        platformLabel.text = ""

        if let post = post {
            if let time = post.postingTime.time,
               let hour = time.hour,
               let minute = time.minute {
                timeLabel.text = String(format: "%02d:%02d", hour, minute)
            }

            titleLabel.text = post.name
            titleLabel.numberOfLines = 0
            dayLabel.text = post.postingTime.day

            let platform = post.platform.first?.lowercased() ?? ""
            platformLabel.text = platform.capitalized
            return
        }

        if let task = task {
            if let time = task.startDate.time,
               let hour = time.hour,
               let minute = time.minute {
                timeLabel.text = String(format: "%02d:%02d", hour, minute)
            }

            titleLabel.text = task.name
            titleLabel.numberOfLines = 0
            dayLabel.text = task.startDate.day
            platformLabel.text = "Task"
            return
        }

        if let deal = deal,
           let deliverable = deal.deliverable.first {

            if let time = deliverable.deadline.time,
               let hour = time.hour,
               let minute = time.minute {
                timeLabel.text = String(format: "%02d:%02d", hour, minute)
            }

            titleLabel.text = deal.name
            titleLabel.numberOfLines = 0
            dayLabel.text = deliverable.deadline.day
            platformLabel.text = deal.platform.first?.capitalized ?? "Deal"
            return
        }
    }
}
