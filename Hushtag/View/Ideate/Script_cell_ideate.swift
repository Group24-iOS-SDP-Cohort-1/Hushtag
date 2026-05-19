import UIKit

class Script_cell_ideate: UICollectionViewCell {
    @IBOutlet var progressView: CircularProgressView!

    @IBOutlet var title: UILabel!

    @IBOutlet var badgeStack: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 12
        applyLiquidGlassEffect()
        title.numberOfLines = 2
    }

    func configureCell(with script: ScriptedIdea) {
        // 1. Title
        if let realTitle = script.title, !realTitle.isEmpty {
            title.text = realTitle
            title.textColor = .label
        } else {
            title.text = "Untitled Script"
        }

        // 2. Badge Logic
        if script.idea_id != nil {
            configureHashtags("Idea")
        } else {
            configureHashtags("Chatbot")
        }

        // 3. Progress
        let totalCriteria: Float = 3.0
        var filledCriteria: Float = 0.0

        if let t = script.title, !t.isEmpty { filledCriteria += 1 }
        if let d = script.description, !d.isEmpty { filledCriteria += 1 }
        if let s = script.script, !s.isEmpty { filledCriteria += 1 }

        let progress = filledCriteria / totalCriteria
        progressView.setProgress(value: progress)
    }

    func configureHashtags(_ hashtag: String) {
        for arrangedSubview in badgeStack.arrangedSubviews {
            badgeStack.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }

        let badge = Badges.loadFromNib()

        badge.configure(
            text: hashtag,
            color: .white,
            cornerRadius: 12,
            borderWidth: 0.0,
            backgroundAlpha: 0.12
        )

        badgeStack.addArrangedSubview(badge)
    }
}
