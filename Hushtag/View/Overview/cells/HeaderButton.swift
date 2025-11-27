//
//  HeaderButton.swift
//  Hushtag
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class HeaderButton: UICollectionReusableView {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var popupButton: UIButton!
    
    var onFilterSelected: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        popupButton.showsMenuAsPrimaryAction = true
        setupPopupMenu()
    }
    func configure() {
        headerLabel.text = "Engagement Rate"
    }
    
    func setupPopupMenu() {
    
        let option1 = UIAction(title: "Past week") { _ in
            self.popupButton.setTitle("Past week", for: .normal)
            self.onFilterSelected?("week")
        }

        let option2 = UIAction(title: "Past month") { _ in
            self.popupButton.setTitle("Past month", for: .normal)
            self.onFilterSelected?("month")
        }

        let option3 = UIAction(title: "Past 3 weeks") { _ in
            self.popupButton.setTitle("Past month", for: .normal)
            self.onFilterSelected?("3weeks")
        }

        popupButton.menu = UIMenu(title: "", children: [option1, option2, option3])
        popupButton.showsMenuAsPrimaryAction = true
    }

}
