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

    private var post: Post?
    private var deal: Deal?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        applyLiquidGlassEffect()
    }
    func configureCell(_ post: Post?, _ deal: Deal?) {

        self.post = post
        self.deal = deal

        timeLabel.text = "--:--"
        titleLabel.text = ""
        dayLabel.text = ""

        if let post = post,
           let task = post.tasks?.first {

            if let time = task.deadline.time,
               let hour = time.hour,
               let minute = time.minute {
                timeLabel.text = String(format: "%02d:%02d", hour, minute)
            }

            titleLabel.text = post.name
            dayLabel.text = task.deadline.day

            updateCompletedButton(isCompleted: post.isCompleted)
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
            dayLabel.text = deliverable.deadline.day

            updateCompletedButton(isCompleted: deal.isCompleted)
            return
        }
    }
    private func updateCompletedButton(isCompleted: Bool) {
        let imageName = isCompleted ? "checkmark.circle.fill" : "circle"
        completedButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.didTapCompleted(post: post, deal: deal)
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
    func didTapCompleted(post: Post?, deal: Deal?)
}

