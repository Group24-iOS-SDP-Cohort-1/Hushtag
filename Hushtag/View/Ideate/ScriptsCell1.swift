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
    
    func configureCell(idea : Idea) {
        Title.text = idea.title
        Description.text = idea.description
        configureHashtags(idea.hashtag)
        let totalCriteria: Float = 4.0
        var filledCriteria: Float = 0.0
            
        if !idea.title.isEmpty {
            filledCriteria += 1
        }
            
        if !idea.description.isEmpty {
            filledCriteria += 1
        }
            
        if ((idea.script?.isEmpty) == nil) {
            filledCriteria += 1
        }
            
        if ((idea.thumbnail?.isEmpty) == nil) {
            filledCriteria += 1
        }
            
        //Calculating Percentage of completion
        let progress = filledCriteria / totalCriteria
            
        //Setting Progress
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
