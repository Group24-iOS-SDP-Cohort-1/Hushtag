//
//  AnalysisCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class AnalysisCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureCell(analysis: Analysis, category: String) {
        valueLabel.text = analysis.engagementRate
        platformLabel.text = category
        if category == "Youtube" {
            platformLabel.textColor = UIColor(hex: "BD081C")
        } else if category == "Instagram" {
            platformLabel.textColor = UIColor(hex: "8134AF")
        } else {
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
