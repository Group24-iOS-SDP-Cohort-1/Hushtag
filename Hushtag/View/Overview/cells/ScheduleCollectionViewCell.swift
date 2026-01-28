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
            titleLabel.text = post.name
            
            // Supabase-driven state
            updateCompletedButton(isCompleted: post.isCompleted)
            
        case .deal(let deal, let deliverable):
            
            timeLabel.text = deliverable.deadline.formatted(
                date: .omitted,
                time: .shortened
            )
            
            dayLabel.text = deliverable.deadline.dayOnly()
            titleLabel.text = deal.name
            
            // Supabase-driven state
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

protocol ScheduleCollectionViewCellDelegate: AnyObject {
    func didTapCompleted(item: ScheduleItem?)
}
