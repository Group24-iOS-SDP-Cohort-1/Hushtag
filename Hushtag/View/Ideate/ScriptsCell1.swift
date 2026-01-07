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
    
    
    @IBOutlet weak var Hashtag: UILabel!
    
    
    @IBOutlet weak var progressView: CircularProgressView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = false
        applyLiquidGlassEffect()
        //        self.layer.shadowColor = UIColor.black.cgColor
        //        self.layer.shadowOpacity = 0.15
        //        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        //        self.layer.shadowRadius = 6
        //        self.backgroundColor = .white
        //Title.font = .systemFont(ofSize: 14, weight: .regular)
        Title.numberOfLines = 3
        Description.numberOfLines = 2
        Description.textColor = .secondaryLabel
        
    }
    
    func configureCell(idea : Idea) {

        Title.text = idea.title
        Description.text = idea.description
        Hashtag.text = idea.hashtag.map { "#\($0)" }.joined(separator: " ")
        Hashtag.textColor = .accent
        
        //progressView.setProgress(value: progress)
        
        let totalCriteria: Float = 4.0
            var filledCriteria: Float = 0.0
            
            // Check Title
            if !idea.title.isEmpty {
                filledCriteria += 1
            }
            
            // Check Description
            if !idea.description.isEmpty {
                filledCriteria += 1
            }
            
            // Check Script
            if !idea.script.isEmpty {
                filledCriteria += 1
            }
            
            // Check Thumbnail (assuming it's a URL string or image name)
            if !idea.thumbnail.isEmpty {
                filledCriteria += 1
            }
            
            // 3. Calculate percentage (e.g., 3/4 = 0.75)
            let progress = filledCriteria / totalCriteria
            
            // 4. Update the view
            progressView.setProgress(value: progress)
    }
}
