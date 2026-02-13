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
    
    private let checkedSymbolName = "checkmark.square.fill"
    private let uncheckedSymbolName = "square"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        checkMarkImage.contentMode = .scaleAspectFit
        checkMarkImage.tintColor = .accent
        
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
        checkMarkImage.tintColor = checked ? .accent : UIColor.systemGray

            if animated {
                UIView.animate(withDuration: 0.14) {
                    self.layoutIfNeeded()
                }
            }
        }
    
    func configureCell(with goalTitle : String) {
        contentGoalLabel.text = goalTitle
    }
}
