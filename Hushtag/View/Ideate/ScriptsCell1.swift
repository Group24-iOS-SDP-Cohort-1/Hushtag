//
//  ScriptsCell1.swift
//  Hushtag
//
//  Created by SDC-USER on 18/12/25.
//

import UIKit

class ScriptsCell1: UICollectionViewCell {
    
    
    @IBOutlet weak var Title: UILabel!
    
    
    @IBOutlet weak var Description: UILabel!

    @IBOutlet weak var progressView: CircularProgressView!
    
    
    @IBOutlet weak var badgeStack: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 12
        applyLiquidGlassEffect()
        Title.numberOfLines = 3
        Description.numberOfLines = 1
        Description.textColor = .secondaryLabel
}
    
    func configureCell(with script: ScriptedIdea) {
        if let realTitle = script.title, !realTitle.isEmpty {
            Title.text = realTitle
            Title.textColor = .label // Standard color for user-selected title
        } else {
            Title.text = script.mockTitle ?? "Untitled Script"
            // Optional: You could make mock text slightly lighter to differentiate
            // Title.textColor = .secondaryLabel
        }
        
        // Description: Use real desc -> fallback to Mock -> fallback to Empty
        if let realDesc = script.description, !realDesc.isEmpty {
            Description.text = realDesc
        } else {
            Description.text = script.mockDescription ?? "No description available"
        }
        
        // Tags
        configureHashtags(script.tags ?? [])
        
        // 2. Calculate Progress
        let totalCriteria: Float = 4.0
        var filledCriteria: Float = 0.0
            
        // Check if Title exists AND is not empty
        if let title = script.title, !title.isEmpty {
            filledCriteria += 1
        }
            
        // Check if Description exists AND is not empty
        if let desc = script.description, !desc.isEmpty {
            filledCriteria += 1
        }
            
        // Check if Script body exists AND is not empty
        if let scriptContent = script.script, !scriptContent.isEmpty {
            filledCriteria += 1
        }
            
        // Check if Thumbnail URL exists AND is not empty
        if let thumb = script.thumbnailURL, !thumb.isEmpty {
            filledCriteria += 1
        }
            
        // 3. Set Progress
        let progress = filledCriteria / totalCriteria
        progressView.setProgress(value: progress)
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
}
