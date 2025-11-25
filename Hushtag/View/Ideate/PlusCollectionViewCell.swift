//
//  PlusCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 20/11/25.
//

import UIKit

class PlusCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var plusLabel: UILabel!

    @IBOutlet weak var ideaDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        // Card Styling
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .accent
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.masksToBounds = false

        // Title Label (plusLabel)
        plusLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        plusLabel.textColor = UIColor.label

        // Description Label
        ideaDescription.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        ideaDescription.textColor = UIColor.secondaryLabel
        ideaDescription.numberOfLines = 3
    }
    func configureCell(idea : Idea) {
       
        plusLabel.text = idea.title
        ideaDescription.text = idea.description
        }
}
