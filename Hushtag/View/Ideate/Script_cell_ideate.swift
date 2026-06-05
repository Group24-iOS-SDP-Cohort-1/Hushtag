import UIKit

@objc(Script_cell_ideate)
class ScriptCellIdeate: UICollectionViewCell {
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
        if script.ideaId != nil {
            configureHashtags("Idea")
        } else {
            configureHashtags("Chatbot")
        }

        // 3. Progress
        let totalCriteria: Float = 3.0
        var filledCriteria: Float = 0.0

        if let scriptTitle = script.title, !scriptTitle.isEmpty { filledCriteria += 1 }
        if let scriptDesc = script.description, !scriptDesc.isEmpty { filledCriteria += 1 }
        if let scriptText = script.script, !scriptText.isEmpty { filledCriteria += 1 }

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
