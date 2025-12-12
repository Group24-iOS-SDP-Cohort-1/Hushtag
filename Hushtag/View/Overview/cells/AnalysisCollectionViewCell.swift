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
            symbolName = "arrow.up.circle.fill"
            symbolColor = .systemGreen
        } else if rateValue < 0 {
            symbolName = "arrow.down.circle.fill"
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
