//
//  IdeaCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class IdeaCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var trendingLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var hashtagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureCell(ideas: Idea) {
        trendingLabel.text = "Trending in " + ideas.hashtag[0]
        titleLabel.text = ideas.title
        titleLabel.numberOfLines = 0
        descriptionLabel.text = ideas.description
        hashtagLabel.text = "#" + ideas.hashtag[1] + "  #" + ideas.hashtag[1]
    }

}
