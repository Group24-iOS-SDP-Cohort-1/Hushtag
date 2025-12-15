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
    
    @IBOutlet weak var sfSymbol: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
    func configureCell(value: String, type: String) {
        var absoluteValue = value
        
        if absoluteValue.hasPrefix("-") {
            absoluteValue.removeFirst()
        }
        
        analysisValue.text = "\(absoluteValue)%"
        if absoluteValue.isEmpty {
            analysisValue.text = "--"
        }
        analysisType.text = type
        //analysisValue.text = value
        
        let rateValue = Double(value) ?? 0
        
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
        
//        if type == "Followers" {
//            sfSymbol.isHidden = true
//            analysisValue.text = "\(absoluteValue)"
//        }
        
        
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
