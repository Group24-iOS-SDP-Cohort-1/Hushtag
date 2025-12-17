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
    @IBOutlet weak var sfSymbol: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        applyLiquidGlassEffect()
        
    }
    func configureCell(analysis: Analysis, category: String) {
        var displayRate = analysis.engagementRate

        // remove minus sign for negative values
        if displayRate.hasPrefix("-") {
            displayRate.removeFirst()
        }

        valueLabel.text = "\(displayRate)%"
        if displayRate.isEmpty {
            valueLabel.text = "--"
        }

        let rateString = analysis.engagementRate
        let rateValue = Double(rateString) ?? 0

        var symbolName = "minus.circle.fill"
        var symbolColor: UIColor = .gray

        if rateValue > 0 {
            symbolName = "chevron.up.2"
            symbolColor = .systemGreen
        } else if rateValue < 0 {
            symbolName = "chevron.down.2"
            symbolColor = .systemRed
        }

        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        sfSymbol.image = UIImage(systemName: symbolName, withConfiguration: config)
        sfSymbol.tintColor = symbolColor

        platformLabel.text = category
        if category.lowercased() == "youtube" {
            platformLabel.text = "Youtube"
            platformLabel.textColor = UIColor(hex: "BD081C")

        } else if category.lowercased() == "instagram" {
            platformLabel.text = "Instagram"
            platformLabel.textColor = UIColor(hex: "8134AF")

        } else {
            platformLabel.text = "Facebook"
            platformLabel.textColor = UIColor(hex: "1877F2")
        }
    }
}
