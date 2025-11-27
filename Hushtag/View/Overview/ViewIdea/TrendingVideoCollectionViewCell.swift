//
//  TrendingVideoCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class TrendingVideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    func configureVideo(video: Video) {
        imageView.image = UIImage(named: video.url)
        titleLabel.text = video.videoTitle
        titleLabel.numberOfLines = 0
        viewsLabel.text = "\(video.views) views"
    }

}
