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
        //configureEngagement(idea.engagementTag)

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

//    private func configureEngagement(_ engagementTag: String) {
//
//        if engagementTag.lowercased().contains("trending") {
//            engagementLabel.text = "🔥 Trending"
//            engagementLabel.textColor = .systemRed
//        } else if engagementTag.lowercased().contains("enagaging")  {
//            engagementLabel.text = "⚡ Engaging"
//            engagementLabel.textColor = .label
//        } else {
//            engagementLabel.text = "⚡ Trending"
//            engagementLabel.textColor = .label
//        }
//    }

//    private func configureEngagementTag(_ engagementTag: String) {
//        let symbolName: String
//        let text: String
//        let color: UIColor
//
//        if engagementTag.lowercased().contains("trending") {
//            symbolName = "flame.fill"
//            text = " Trending"
//            color = .systemRed
//        } else if engagementTag.lowercased().contains("engaging") {
//            symbolName = "bolt.fill"
//            text = " Engaging"
//            color = UIColor.systemYellow
//        } else {
//            symbolName = "sparkles"
//            text = " Trending"
//            color = .label
//        }
//
//        let attachment = NSTextAttachment()
//        if let image = UIImage(systemName: symbolName)?.withTintColor(color, renderingMode: .alwaysOriginal) {
//            attachment.image = image
//            // optional: adjust size
//            attachment.bounds = CGRect(x: 0, y: -2, width: 16, height: 16)
//        }
//
//        let attributedString = NSMutableAttributedString(attachment: attachment)
//        attributedString.append(NSAttributedString(string: text, attributes: [.foregroundColor: color, .font: UIFont.systemFont(ofSize: 14, weight: .semibold)]))
//
//        engagementLabel.attributedText = attributedString
//    }




}
