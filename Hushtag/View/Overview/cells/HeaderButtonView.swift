//
//  HeaderButtonView.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class HeaderButtonView: UICollectionReusableView {

    @IBOutlet weak var headerLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureHeader(text: String) {
        headerLabel.text = text
    }
}
