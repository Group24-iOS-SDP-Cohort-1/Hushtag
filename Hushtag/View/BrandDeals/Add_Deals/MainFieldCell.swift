//
//  MainFieldCell.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class MainFieldCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        contentView.layer.cornerRadius = 15
        contentView.clipsToBounds = true
        contentView.applyLiquidGlassEffect()

        textField.borderStyle = .none
        textField.backgroundColor = .clear
        
    }
}
