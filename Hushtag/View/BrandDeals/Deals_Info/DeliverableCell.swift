//
//  DeliverableCell.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class DeliverableCell: UITableViewCell {

    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(with deliverable: Deliverable) {
            titleLabel.text = deliverable.name

            let day  = deliverable.deadline.day ?? ""
            let date = (deliverable.deadline.date ?? "").prefix(10)   // "2025-11-19"
            subtitleLabel.text = "Due \(day) \(date)"

            let iconName = deliverable.isCompleted ? "checkmark.circle.fill" : "circle"
            statusImageView.image = UIImage(systemName: iconName)
        }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
