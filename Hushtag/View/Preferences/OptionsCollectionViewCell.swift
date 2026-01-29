//
//  OptionsCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class OptionsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var buttonLabel: UILabel!
    
    let customPurple = UIColor(red: 139/255, green: 92/255, blue: 246/255, alpha: 1)
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        setupStyle()
    }
    
    func setupStyle() {
        // Round corners to make it look like a pill/button
//        self.layer.cornerRadius = 18
//        self.layer.borderWidth = 1
//        self.layer.borderColor = customPurple.cgColor
//        self.backgroundColor = .white
//        self.buttonLabel.textColor = customPurple
        
        
        self.layer.cornerRadius = 18
        self.layer.borderWidth = 1
        self.layer.borderColor = customPurple.cgColor
        self.buttonLabel.textColor = customPurple
        contentView.applyLiquidGlassEffect()
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                // Selected State: Purple Border & Background
                self.layer.borderColor = customPurple.cgColor
                self.backgroundColor = customPurple
                self.buttonLabel.textColor = .white
                
                if let basicText = buttonLabel.text {
                    
                        buttonLabel.attributedText = .symbolPrefixedText(
                            symbol: "xmark",
                            text: basicText,
                            font: buttonLabel.font,
                            color: buttonLabel.textColor
                        )
                    
                }
            } else {
                // Unselected State: Gray Border & White
                self.layer.borderColor = customPurple.cgColor
                self.backgroundColor = .clear
                self.buttonLabel.textColor = customPurple
                
                buttonLabel.removeSymbolPrefix()
            }
        }
    }
    
    func configureCell(with buttonName : String) {
        buttonLabel.text = buttonName
    }

}



extension NSAttributedString {
    static func symbolPrefixedText(symbol: String, text: String, font: UIFont, color: UIColor) -> NSAttributedString {
        let config = UIImage.SymbolConfiguration(pointSize: font.pointSize, weight: .regular)
        let image = UIImage(systemName: symbol, withConfiguration: config)?
            .withRenderingMode(.alwaysTemplate)

        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(
            x: 0,
            y: (font.capHeight - font.pointSize) / 2,   // auto alignment
            width: font.pointSize,
            height: font.pointSize
        )

        let symbolString = NSAttributedString(attachment: attachment)

        let textString = NSAttributedString(
            string: " " + text,
            attributes: [.font: font, .foregroundColor: color]
        )

        let combined = NSMutableAttributedString()
        combined.append(symbolString)
        combined.append(textString)

        return combined
    }
}



extension UILabel {
    func removeSymbolPrefix() {
        // If there's no attributed text, nothing to remove
        guard let attr = self.attributedText else { return }

        // Extract the plain text part (everything after the symbol)
        let full = attr.string

        // Your prefix always adds a space before the text: " text"
        // So full = " text" → trim the leading space
        let trimmed = full.trimmingCharacters(in: .whitespaces)

        // Reset to plain text
        self.attributedText = nil
        self.text = trimmed
    }
}
