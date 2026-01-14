//
//  HeaderButton.swift
//  Hushtag
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class HeaderButton: UICollectionReusableView {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var backward: UIButton!
    @IBOutlet weak var forward: UIButton!
    var onDateChanged: ((Date) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    func configure(text: String) {
        headerLabel.text = text
    }

}
