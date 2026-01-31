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
            
        case .post(let post, let task):
            
            timeLabel.text = task.deadline.formatted(
                date: .omitted,
                time: .shortened
            )
            
            dayLabel.text = task.deadline.dayOnly()
            titleLabel.text = task.name.isEmpty ? post.name : task.name
            
            // Supabase-driven state
            updateCompletedButton(isCompleted: task.isCompleted)
            
        case .deal(let deal, let deliverable):
            
            timeLabel.text = deliverable.deadline.formatted(
                date: .omitted,
                time: .shortened
            )
            
            dayLabel.text = deliverable.deadline.dayOnly()
            titleLabel.text = deliverable.name.isEmpty ? deal.name : deliverable.name
            
            // Supabase-driven state
            updateCompletedButton(isCompleted: deliverable.isCompleted)
        }
    }
    
    
    private func updateCompletedButton(isCompleted: Bool) {
        let imageName = isCompleted ? "largecircle.fill.circle" : "circle"
        completedButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.didTapCompleted(item: item)
        guard let item = item else { return }
        let newValue: Bool
        switch item {
        case .post(_, let task):
            newValue = task.isCompleted
            
        case .deal(_, let deliverable):
            newValue = deliverable.isCompleted
        }
        updateCompletedButton(isCompleted: newValue)
    }
}

protocol ScheduleCollectionViewCellDelegate: AnyObject {
    func didTapCompleted(item: ScheduleItem?)
}
