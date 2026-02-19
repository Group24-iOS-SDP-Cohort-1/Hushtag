//
//  IdeaDetailsCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 13/02/26.
//

import UIKit

class IdeaDetailsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var valuesLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var gapLabel: UILabel!
    @IBOutlet weak var badgeStack: UIStackView!
    
    var idea: Idea?
    
    
    func configure(with idea: Idea) {
        titleLabel.text = idea.title
        descriptionLabel.text = idea.description
        if let expanded = idea.expandedDescription,
           !expanded.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            // Already expanded → show directly
            descriptionLabel.text = expanded
            
        } else {
            
            // Show original first
            descriptionLabel.text = idea.description
            
            // Call AI only once
            Task {
                await expandDescriptionWithAI()
            }
        }
    }
    
    func configureStatistic(_ value: Int, _ label: String) {
        applyLiquidGlassEffect()
        valuesLabel.text = value.formattedCount()
        categoryLabel.text = label
    }
    
    func configureHashtag(_ hashtags: [String]) {
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
    
    func expandDescriptionWithAI() async {

        guard let idea = idea else { return }

        let prompt = """
        Expand this YouTube idea description into 4–5 engaging lines.
        Keep it natural, simple, and readable.

        Original:
        "\(idea.description)"
        """

        do {
            let expanded = try await AppleIntelligenceManager.shared.askSafely(prompt: prompt)

            DispatchQueue.main.async {
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
            }
        }
    
    
    
    
    //        hashtagLabel.text = idea.hashtags.joined(separator: "   ")
    //        video = idea.videos ?? []
    //
}
