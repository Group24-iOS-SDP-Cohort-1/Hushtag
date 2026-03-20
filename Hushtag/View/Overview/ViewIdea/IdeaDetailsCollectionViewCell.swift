import UIKit

class IdeaDetailsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var gapLabel: UILabel!
    @IBOutlet weak var badgeStack: UIStackView!
    @IBOutlet weak var valuesLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var view: UIView!
    
    
    var idea: Idea?
    let controller = ScriptedIdeasController()
    var onContentUpdated: (() -> Void)?
    
    func configure(with idea: Idea) {
        self.idea = idea
        titleLabel.text = idea.title
        descriptionLabel.text = idea.description
        if let expanded = idea.expandedDescription,
           !expanded.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            descriptionLabel.text = expanded
            
        } else {
            descriptionLabel.text = idea.description
            
            Task {
                await expandDescriptionWithAI()
            }
        }
    }
    
    func configureStatistic(_ value: Int, _ symbolName: String) {
        applyLiquidGlassEffect()
        valuesLabel.text = value.formattedCount()
        imageView.image = UIImage(systemName: symbolName)
    }
    
    func configureHashtag(_ hashtags: [String]) {
        
        // Remove old badges
        badgeStack.arrangedSubviews.forEach {
            badgeStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        badgeStack.axis = .vertical
        badgeStack.spacing = 8
        badgeStack.alignment = .leading
        
        var rowStack: UIStackView?
        
        for (index, tag) in hashtags.enumerated() {
            
            // New row every 3 badges
            if index % 3 == 0 {
                rowStack = UIStackView()
                rowStack?.axis = .horizontal
                rowStack?.spacing = 8
                rowStack?.alignment = .leading
                rowStack?.distribution = .fill   // important fix
                
                if let row = rowStack {
                    badgeStack.addArrangedSubview(row)
                }
            }
            
            let badge: Badges = Badges.loadFromNib()
            
            badge.configure(
                text: "\(tag)",
                color: UIColor(hex: "#a78bfa"),      // purple text — matches #a78bfa
                cornerRadius: 12,                    // pill shape to match
                borderWidth: 1.0,
                backgroundAlpha: 0.12
            )
            
            badge.backgroundColor = UIColor(hex: "#8a6cff").withAlphaComponent(0.12)
            badge.layer.borderColor = UIColor(hex: "#8a6cff").withAlphaComponent(0.22).cgColor
            
            badge.setContentHuggingPriority(.required, for: .horizontal)
            badge.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            rowStack?.addArrangedSubview(badge)
        }
    }
    
    func expandDescriptionWithAI() async {
        
        guard let idea = idea else { return }
        
        let prompt = """
        Expand this YouTube idea description into 4–5 engaging lines.
        Keep it natural, simple, and readable.
        
        Original:
        "\(idea.description)"
        """
        
        do {
            
            let expanded =
            try await AppleIntelligenceManager.shared.askSafely(prompt: prompt)
            try await ScriptedIdeasController()
                .updateExpandedDescription(
                    ideaID: idea.id,
                    expandedDescription: expanded
                )
            
            await MainActor.run {
                self.animateDescriptionUpdate(expanded)
            }
            
        } catch {
            print("Expansion failed:", error.localizedDescription)
        }
    }
    
    func animateDescriptionUpdate(_ newText: String) {
        UIView.transition(
            with: descriptionLabel,
            duration: 0.2,
            options: .transitionCrossDissolve
        ) {
            self.descriptionLabel.text = newText
            self.descriptionLabel.alpha = 1.0
            self.idea?.expandedDescription = newText
        } completion: { _ in
            self.onContentUpdated?()
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255
        
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
