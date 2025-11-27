//
//  HeaderChevronView.swift
//  Hushtag
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class HeaderChevronView: UICollectionReusableView {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var navigationButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(title: String) {
        headerLabel.text = title
    }
}
