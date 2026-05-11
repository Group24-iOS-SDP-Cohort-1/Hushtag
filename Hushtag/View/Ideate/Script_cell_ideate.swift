import UIKit

class Script_cell_ideate: UICollectionViewCell {

    @IBOutlet weak var progressView: CircularProgressView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var badgeStack: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 12
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
        
        badgeStack.arrangedSubviews.forEach {
            badgeStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        let badge: Badges = Badges.loadFromNib()
        
        badge.configure(
            text: hashtag,
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
