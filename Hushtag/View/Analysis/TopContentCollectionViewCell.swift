//
//  TopContentCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 05/01/26.
//

import UIKit

class TopContentCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        thumbnailImageView.layer.cornerRadius = 10
        thumbnailImageView.clipsToBounds = true
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.applyLiquidGlassEffect()
        // Initialization code
    }
    func configure(with item: TopContentItem) {
        titleLabel.text = item.title
        viewsLabel.text = "\(item.views) • \(item.publishedTime)"
        thumbnailImageView.image = UIImage(named: item.thumbnail)
    }

}
