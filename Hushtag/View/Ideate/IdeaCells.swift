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
    @IBOutlet weak var keywordImage1: UIImageView!
    @IBOutlet weak var keywordText1: UILabel!
    @IBOutlet weak var keywordImage2: UIImageView!
    @IBOutlet weak var keywordText2: UILabel!
    var idea: Idea?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ideaView.layer.cornerRadius = 10
        ideaTitle.numberOfLines = 2
        separatorLine.backgroundColor = .separator

        applyLiquidGlassEffect()
    }


    func configure(idea: Idea, keyword1: [String], keyword2: [String]) {
        ideaTitle.text = idea.title
        configureHashtags(idea.hashtag)
        keywordText1.text = keyword1[0]
        keywordText2.text = keyword2[0]
        keywordImage1.image = UIImage(systemName: keyword1[1])
        keywordImage2.image = UIImage(systemName: keyword2[1])
    }
    
    static func loadFromNib() -> Badges {
        let nib = UINib(nibName: "Badges", bundle: nil)
        guard let badge = nib.instantiate(withOwner: nil, options: nil).first as? Badges else {
            fatalError("Failed to load Badges from nib")
        }
        return badge
    }


    private func configureHashtags(_ hashtags: [String]) {

        badgeStack.arrangedSubviews.forEach {
            badgeStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for tag in hashtags {
            let badge: Badges = Badges.loadFromNib()

            badge.configure(text: tag)

            badgeStack.addArrangedSubview(badge)
        }
    }
}
