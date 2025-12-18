//
//  IdeaCells.swift
//  Hushtag
//
//  Created by SDC-USER on 18/12/25.
//

import UIKit

class IdeaCells: UICollectionViewCell {

    @IBOutlet weak var ideaTitle: UILabel!
    
    @IBOutlet weak var ideaDescription: UILabel!

    @IBOutlet weak var ideaView: UIView!

    @IBOutlet weak var badgeStack: UIStackView!

    var idea: Idea?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ideaView.layer.cornerRadius = 10
        ideaTitle.numberOfLines = 2
        ideaDescription.numberOfLines = 3

        applyLiquidGlassEffect()
    }


    func configure(idea: Idea) {
        ideaTitle.text = idea.title
        ideaDescription.text = idea.description
        configureHashtags(idea.hashtag)

    }

    private func configureHashtags(_ hashtags: [String]) {

        badgeStack.arrangedSubviews.forEach {
            badgeStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for tag in hashtags {
            let badge: Badges = Badges.loadFromNib()

            badge.configure(
                text: tag,
                color: .white,          
                cornerRadius: 14,
                borderWidth: 1,
                backgroundAlpha: 0.15
            )

            badgeStack.addArrangedSubview(badge)
        }
    }


}
