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
            
            updateCompletedButton(isCompleted: deliverable.isCompleted)
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
