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
protocol IdeaCellDelegate: AnyObject {
    func didToggleLikeFromFeed(for ideaKey: String)
}


class IdeaCells: UICollectionViewCell {
    @IBOutlet weak var ideaTitle: UILabel!
    @IBOutlet weak var ideaView: UIView!
    @IBOutlet weak var badgeStack: UIStackView!
    @IBOutlet weak var keywordImage2: UIImageView!
    @IBOutlet weak var keywordText2: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    weak var delegate: IdeaCellDelegate?
    private var ideaKey: String?

    var idea: Idea?
    override func awakeFromNib() {
        super.awakeFromNib()
        ideaView.layer.cornerRadius = 10
        ideaTitle.numberOfLines = 2
        applyLiquidGlassEffect()
    }
    

    
    func configure(idea: Idea) {
        self.idea = idea
        ideaTitle.text = idea.title
        configureHashtags(idea.hashtags)
        updateLikeUI()
        keywordText2.text = idea.format
    }
    
    private func configureHashtags(_ hashtags: [String]) {
        badgeStack.arrangedSubviews.forEach {
            badgeStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        for tag in hashtags.prefix(2) {
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
    
    @IBAction func likeTapped(_ sender: UIButton) {
        guard var idea = idea else { return }
        idea.liked = !(idea.liked ?? false)
        self.idea = idea
        updateLikeUI()
        delegate?.didToggleLikeFromFeed(for: idea.ideaKey)

    }
    
    private func updateLikeUI() {
            guard let idea = idea else { return }
            let isLiked = idea.liked == true
            let imageName = isLiked ? "heart.fill" : "heart"
            likeButton.setImage(UIImage(systemName: imageName), for: .normal)
        }


    
    
}
