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
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var categoryStack: UIStackView!
    @IBOutlet weak var iconStack: UIStackView!
    override func awakeFromNib() {
        super.awakeFromNib()
        applyLiquidGlassEffect()
    }
    func configureCell(analysis: Analysis, category: String, state: Int) {
        valueLabel.text = analysis.followers.isEmpty ? "--" : analysis.followers
        
        if state == 1 {
            switch category.lowercased() {
            case "youtube":
                platformLabel.text = "YouTube"
                platformLabel.textColor = UIColor(hex: "FF4E45")
                icon.image = UIImage(named: "youtube_icon")
                
            case "instagram":
                platformLabel.text = "Instagram"
                platformLabel.textColor = UIColor(hex: "E440FF")
                icon.image = UIImage(named: "instagram_icon")
                
            case "twitter":
                platformLabel.text = "X (Twitter)"
                platformLabel.textColor = UIColor(hex: "4DA3FF")
                icon.image = UIImage(named: "twitter_icon")
                
            default:
                icon.image = nil
            }
            
        } else {
            platformLabel.text = "Followers"
        }
        switch category.lowercased() {
        case "youtube":
            icon.image = UIImage(named: "youtube_icon")
            
        case "instagram":
            icon.image = UIImage(named: "instagram_icon")
            
        case "twitter":
            icon.image = UIImage(named: "twitter_icon")
            
        default:
            icon.isHidden = true
        }
    }
}
