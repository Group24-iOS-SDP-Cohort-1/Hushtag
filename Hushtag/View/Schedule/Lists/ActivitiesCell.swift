//
//  ActivitiesCell.swift
//  Hushtag
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class ActivitiesCell: UICollectionViewCell {
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var sfLabel: UILabel!
    
    func configure(_ activites: String, _ value: Int, _ sf: String) {
        valueLabel.text = "\(value)"
        categoryLabel.text = activites
        
        let config = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 32))
        let image = UIImage(systemName: sf, withConfiguration: config)?.withTintColor(.accent) ?? UIImage()
        let attachment = NSTextAttachment()
        attachment.image = image
        let attributed = NSAttributedString(attachment: attachment)
        sfLabel.attributedText = attributed
        
        layer.cornerRadius = 12
        layer.masksToBounds = false
        applyLiquidGlassEffect()
    }
}
