//
//  IdeaCells.swift
//  Hushtag
//
//  Created by SDC-USER on 18/12/25.
//

import UIKit

class IdeaCells: UICollectionViewCell {

    @IBOutlet weak var ideaTitle: UILabel!

    @IBOutlet weak var ideaView: UIView!

    @IBOutlet weak var badgeStack: UIStackView!

    @IBOutlet weak var separatorLine: UIView!

    @IBOutlet weak var engagementLabel: UILabel!

    
    @IBOutlet weak var engagementImage: UIImageView!

    var idea: Idea?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ideaView.layer.cornerRadius = 10
        ideaTitle.numberOfLines = 2
        separatorLine.backgroundColor = .separator

        applyLiquidGlassEffect()
    }


    func configure(idea: Idea) {
        ideaTitle.text = idea.title
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
                cornerRadius: 10,
                borderWidth: 0.2,
                backgroundAlpha: 0.10
            )

            badgeStack.addArrangedSubview(badge)
        }
    }




}
