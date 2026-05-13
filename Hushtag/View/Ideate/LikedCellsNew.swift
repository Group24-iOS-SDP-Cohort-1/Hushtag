import UIKit

protocol LikedCellDelegate: AnyObject {
    func didTapDraftScript(for idea: Idea)
    func didToggleLike(for ideaKey: String)
}

class LikedCellsNew: UICollectionViewCell {
    @IBOutlet weak var ideaTitle: UILabel!
    @IBOutlet weak var ideaView: UIView!
    @IBOutlet weak var badgeStack: UIStackView!

    weak var delegate: LikedCellDelegate?
    var idea: Idea?
    var onLikeToggle: (() -> Void)?
    @IBOutlet weak var likeButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ideaView.layer.cornerRadius = 10
        applyLiquidGlassEffect()
    }

    func configureCell(idea: Idea){
        self.idea = idea
        ideaTitle.text = idea.title
        updateLikeUI()
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

    @IBAction func likeTapped(_ sender: UIButton) {
        guard let idea = idea else { return }
        delegate?.didToggleLike(for: idea.ideaKey ?? "")
    }
    
    func updateLikeUI() {
        guard let idea = idea else { return }
        let isLiked = idea.liked == true
        let imageName = isLiked ? "bookmark.fill" : "bookmark"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @objc private func draftScriptTapped() {
            guard let idea = idea else { return }
            delegate?.didTapDraftScript(for: idea)
   }

}
