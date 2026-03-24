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

    func configureHashtags(_ hashtags: [String]) {
        badgeStack.arrangedSubviews.forEach {
            badgeStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        for tag in hashtags.prefix(2)  {
            let badge: Badges = Badges.loadFromNib()

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

    @IBAction func likeTapped(_ sender: UIButton) {
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
