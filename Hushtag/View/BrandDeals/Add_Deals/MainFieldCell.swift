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
        // Initialization code
        selectionStyle = .none
                
                textField.borderStyle = .none
                textField.backgroundColor = .clear
                
                // Placeholder style (light gray)
                textField.attributedPlaceholder = NSAttributedString(
                    string: textField.placeholder ?? "",
                    attributes: [.foregroundColor: UIColor.secondaryLabel]
                )
                
                // Text font
                textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
                textField.textColor = .label
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
