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
    var indexPath: IndexPath?
    
    private var item: ScheduleItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyLiquidGlassEffect()
    }
    
    func configure(with item: ScheduleItem) {
        self.item = item
        dayLabel.text = item.effectiveDeadline.dayOnly()
        switch item {
        case .post(let post, let task):
            if let task = task {
                // It's a sub-task
                titleLabel.text = task.name
                timeLabel.text = task.deadline.timeOnly()
                // set completed status for task
            } else {
                // It's the MAIN Post
                titleLabel.text = "Post: \(post.name)"
                timeLabel.text = post.deadline.timeOnly()
                // hide complete button or set it to false
            }
            
        case .deal(let deal, let deliverable):
            if let deliverable = deliverable {
                // It's a sub-deliverable
                titleLabel.text = deliverable.name
                timeLabel.text = deliverable.deadline.timeOnly()
                // set completed status for deliverable
            } else {
                // It's the MAIN Deal
                titleLabel.text = "Deal: \(deal.name)"
                timeLabel.text = deal.deadline.timeOnly()
                // set completed status based on deal.isManuallyCompleted
            }
        }
    }
    
    
    
    private func updateCompletedButton(isCompleted: Bool) {
        let imageName = isCompleted ? "largecircle.fill.circle" : "circle"
        completedButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        guard let item = item,
              let indexPath = indexPath else {
            return
        }
        
        delegate?.didTapCompleted(item: item, indexPath: indexPath)
    }
}

protocol ScheduleCollectionViewCellDelegate: AnyObject {
    func didTapCompleted(item: ScheduleItem, indexPath: IndexPath)
}
