//
//  RevenueSourceCell.swift
//  Hushtag
//
//  Created by SDC-USER on 06/01/26.
//

import UIKit

class RevenueSourceCell: UICollectionViewCell {

    @IBOutlet weak var sfSymbol: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        applyLiquidGlassEffect()
    }
    func configure(with data: RevenueSource) {
        nameLabel.text = data.name
        nameLabel.numberOfLines = 0
        amountLabel.text = "Rs." + data.amount
        sfSymbol.image = UIImage(systemName: data.sf)
    }

}
