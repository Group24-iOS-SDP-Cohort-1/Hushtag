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
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
    func configureCell(value: String, type: String) {
        analysisValue.text = value
        analysisType.text = type
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
