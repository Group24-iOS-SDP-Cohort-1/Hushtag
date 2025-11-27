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
    }
    func configureCell(schedule: Post) {
        let hour = schedule.postingTime.time.hour
        let minute = schedule.postingTime.time.minute

        timeLabel.text = "\(hour):\(String(format: "%02d", minute))"

        titleLabel.text = schedule.name
        titleLabel.numberOfLines = 0
        dayLabel.text = schedule.postingTime.day
        if schedule.platform.first == "youtube" {
            platformLabel.text = "Youtube"
            platformLabel.textColor = UIColor(hex: "BD081C")
        } else if schedule.platform.first == "instagram" {
            platformLabel.text = "Instagram"
            platformLabel.textColor = UIColor(hex: "8134AF")
        } else {
            platformLabel.text = "Facebook"
            platformLabel.textColor = UIColor(hex: "1877F2")
        }
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        layer.cornerRadius = 12
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 8
        backgroundColor = .clear
        contentView.backgroundColor = .white
    }
}
