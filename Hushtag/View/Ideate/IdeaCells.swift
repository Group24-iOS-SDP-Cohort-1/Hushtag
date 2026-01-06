//
//  IdeaCells.swift
//  Hushtag
//
//  Created by SDC-USER on 18/12/25.
//

import UIKit

struct EngagementStyle {
    let text: String
    let icon: String
    let color: UIColor
}
 
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
        ideaView.layer.cornerRadius = 10
        ideaTitle.numberOfLines = 2
        separatorLine.backgroundColor = .separator

        applyLiquidGlassEffect()
    }


    func configure(idea: Idea, keyword1: EngagementStyle, keyword2: EngagementStyle) {
        ideaTitle.text = idea.title
        configureHashtags(idea.hashtag)
//        keywordText1.text = keyword1[0]
//        keywordText2.text = keyword2[0]
//        keywordImage1.image = UIImage(systemName: keyword1[1])
//        keywordImage2.image = UIImage(systemName: keyword2[1])
            keywordText1.text = keyword1.text
            keywordText1.textColor = keyword1.color
            keywordImage1.image = UIImage(systemName: keyword1.icon)
            keywordImage1.tintColor = keyword1.color

            keywordText2.text = keyword2.text
            keywordText2.textColor = keyword2.color
            keywordImage2.image = UIImage(systemName: keyword2.icon)
            keywordImage2.tintColor = keyword2.color
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
                    cornerRadius: 12,
                    borderWidth: 0.2,
                    backgroundAlpha: 0.10
                )

                badgeStack.addArrangedSubview(badge)
            }
        }


}
