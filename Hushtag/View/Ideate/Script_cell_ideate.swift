//
//  Script_cell_ideate.swift
//  Hushtag
//
//  Created by SDC-USER on 18/02/26.
//

import UIKit

class Script_cell_ideate: UICollectionViewCell {

    @IBOutlet weak var progressView: CircularProgressView!
    
    @IBOutlet weak var title: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 12
        applyLiquidGlassEffect()
        title.numberOfLines = 2
    }

    func configureCell(with script: ScriptedIdea) {
        // 1. Set Title
        if let realTitle = script.title, !realTitle.isEmpty {
            title.text = realTitle
            title.textColor = .label
        } else {
            title.text = script.mockTitle ?? "Untitled Script"
        }
        
        // 2. Calculate Progress
        let totalCriteria: Float = 4.0
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
            
        // Check if Thumbnail URL exists AND is not empty
        if let th = script.thumbnailURL, !th.isEmpty {
            filledCriteria += 1
        }
            
        // 3. Set Progress
        let progress = filledCriteria / totalCriteria
        progressView.setProgress(value: progress)
    }

}
