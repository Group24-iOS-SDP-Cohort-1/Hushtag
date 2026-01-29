//
//  ContentGoalsCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class ContentGoalsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var checkMarkImage: UIImageView!
    
    @IBOutlet weak var contentGoalLabel: UILabel!
    
    let customPurple = UIColor(red: 139/255, green: 92/255, blue: 246/255, alpha: 1)
    
    private let checkedSymbolName = "checkmark.square.fill"
    private let uncheckedSymbolName = "square"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        checkMarkImage.contentMode = .scaleAspectFit
        checkMarkImage.tintColor = customPurple
        
        setChecked(false, animated: false)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // restore default visuals
        setChecked(false, animated: false)
    }
    
    override var isSelected: Bool {
        didSet {
            setChecked(isSelected, animated: true)
        }
    }
    
    private func setChecked(_ checked: Bool, animated: Bool) {
            // Use SF Symbols via systemName (preferred). If you used asset images, switch to UIImage(named:).
            let imageName = checked ? checkedSymbolName : uncheckedSymbolName
            let image = UIImage(systemName: imageName)?
                            .withRenderingMode(.alwaysTemplate)

            // apply image and colour
            checkMarkImage.image = image
            checkMarkImage.tintColor = checked ? customPurple : UIColor.systemGray

            // optional cell visuals when selected
        /*
            if checked {
                contentGoalLabel.textColor = customPurple
                contentView.backgroundColor = customPurple.withAlphaComponent(0.06)
                contentView.layer.borderColor = customPurple.cgColor
                contentView.layer.borderWidth = 1
            } else {
                contentGoalLabel.textColor = .label
                contentView.backgroundColor = .clear
                contentView.layer.borderColor = UIColor.clear.cgColor
                contentView.layer.borderWidth = 0
            }
         */

            if animated {
                UIView.animate(withDuration: 0.14) {
                    self.layoutIfNeeded()
                }
            }
        }
    
    /*
    override var isSelected: Bool {
        didSet {
            if isSelected {
                // Selected State: Purple Border & Background
                self.checkMarkImage.image = UIImage(named: "checkmark.square.fill")
            } else {
                // Unselected State: Gray Border & White
                self.checkMarkImage.image = UIImage(named: "checkmark.square")
            }
        }
    }
     */

    
    func configureCell(with goalTitle : String) {
        contentGoalLabel.text = goalTitle
    }
}
