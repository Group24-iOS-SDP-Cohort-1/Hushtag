//
//  HeaderChevronView.swift
//  Hushtag
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class HeaderChevronView: UICollectionReusableView {

    var onTap: (() -> Void)?
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var navigationButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        navigationButton.addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }
    @objc func tapped() {
        onTap?()
    }
    func configure(title: String) {
        headerLabel.text = title
    }
}
