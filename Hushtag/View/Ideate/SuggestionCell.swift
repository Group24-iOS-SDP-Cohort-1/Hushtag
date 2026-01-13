//
//  SuggestionCell.swift
//  Hushtag
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit

class SuggestionCell: UIView {
    @IBOutlet weak var generateButton: UIButton!
    
    override func awakeFromNib() {
        generateButton.layer.borderWidth = 1
        generateButton.layer.borderColor = UIColor.accent.cgColor
    }

}
