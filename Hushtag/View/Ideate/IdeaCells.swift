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
    @IBOutlet var ideaTitle: UILabel!
    @IBOutlet var ideaView: UIView!
    @IBOutlet var badgeStack: UIStackView!
    @IBOutlet var likeButton: UIButton!
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
    }

    func configureHashtags(_ hashtags: [String]) {
        for arrangedSubview in badgeStack.arrangedSubviews {
            badgeStack.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }
        for tag in hashtags.prefix(2) {
            let badge = Badges.loadFromNib()

            badge.configure(
                text: "\(tag)",
                color: UIColor(hex: "#a78bfa"),
                cornerRadius: 12,
                borderWidth: 1.0,
                backgroundAlpha: 0.12
            )

            badge.backgroundColor = UIColor(hex: "#8a6cff").withAlphaComponent(0.12)
            badge.layer.borderColor = UIColor(hex: "#8a6cff").withAlphaComponent(0.22).cgColor

            badgeStack.addArrangedSubview(badge)
        }
    }

    @IBAction func likeTapped(_: UIButton) {
        guard let idea = idea else { return }
        delegate?.didToggleLikeFromFeed(for: idea.ideaKey ?? "")
    }

    func updateLikeUI() {
        guard let idea = idea else { return }
        let isLiked = idea.liked == true
        let imageName = isLiked ? "bookmark.fill" : "bookmark"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}
