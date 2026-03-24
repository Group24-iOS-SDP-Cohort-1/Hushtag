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
        configureHashtags("Chatbot")
    }

    func configureCell(with script: ScriptedIdea) {
        // 1. Set Title
        if let realTitle = script.title, !realTitle.isEmpty {
            title.text = realTitle
            title.textColor = .label
        } else {
            title.text = "Untitled Script"
        }
        
        // 2. Calculate Progress
        let totalCriteria: Float = 3.0
        var filledCriteria: Float = 0.0
            
        // Check if Title exists AND is not empty
        if let t = script.title, !t.isEmpty {
            filledCriteria += 1
        }
            
        // Check if Description exists AND is not empty
        if let d = script.description, !d.isEmpty {
            filledCriteria += 1
        }
            
        // Check if Script body exists AND is not empty
        if let s = script.script, !s.isEmpty {
            filledCriteria += 1
        }
            
        // 3. Set Progress
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
