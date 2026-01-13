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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        applyLiquidGlassEffect()
    }
    func configureCell(_ post: Post?, _ deal: Deal?, _ task: Task?) {
        timeLabel.text = "--:--"
        titleLabel.text = ""
        dayLabel.text = ""

        if let post = post {
            if let time = post.postingTime.time,
               let hour = time.hour,
               let minute = time.minute {
                timeLabel.text = String(format: "%02d:%02d", hour, minute)
            }

            titleLabel.text = post.name
            titleLabel.numberOfLines = 1
            dayLabel.text = post.postingTime.day
            
            return
        }

        if let task = task {
            if let time = task.startDate.time,
               let hour = time.hour,
               let minute = time.minute {
                timeLabel.text = String(format: "%02d:%02d", hour, minute)
            }

            titleLabel.text = task.name
            titleLabel.numberOfLines = 1
            dayLabel.text = task.startDate.day
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
            titleLabel.numberOfLines = 1
            dayLabel.text = deliverable.deadline.day
            return
        }
    }
}
