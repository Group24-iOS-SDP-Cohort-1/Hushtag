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

        self.layer.cornerRadius = 12
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.15
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 6
        self.backgroundColor = .white
        ideaDescription.textColor = UIColor.secondaryLabel
        ideaDescription.numberOfLines = 3
    }
    func configureCell() {
        plusLabel.text = "+"
        plusLabel.textColor = .accent
        plusLabel.font = UIFont.systemFont(ofSize: 40, weight: .regular)
        plusLabel.textAlignment = .center
        ideaDescription.text = "Script with AI"
        }
}
