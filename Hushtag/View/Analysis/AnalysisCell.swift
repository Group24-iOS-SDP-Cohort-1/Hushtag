//
//  AnalysisCell.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class AnalysisCell: UICollectionViewCell {

    @IBOutlet weak var analysisValue: UILabel!
    @IBOutlet weak var analysisType: UILabel!
    
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var sfSymbol: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
    func configureCell(value: String, type: String, change: String) {

        // Main value & title
        analysisValue.text = value
        analysisType.text = type

        // Change label
        changeLabel.text = change

        // Arrow + color based on change (NOT value)
        if change.contains("+") {
            sfSymbol.image = UIImage(systemName: "arrow.up.circle.fill")
            sfSymbol.tintColor = .systemGreen
            changeLabel.textColor = .systemGreen
            sfSymbol.isHidden = false
        } else if change.contains("-") {
            sfSymbol.image = UIImage(systemName: "arrow.down.circle.fill")
            sfSymbol.tintColor = .systemRed
            changeLabel.textColor = .systemRed
            sfSymbol.isHidden = false
        } else {
            sfSymbol.isHidden = true
            changeLabel.textColor = .secondaryLabel
        }

        // Styling
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.applyLiquidGlassEffect()
        backgroundColor = .clear
    }
    
    
}
