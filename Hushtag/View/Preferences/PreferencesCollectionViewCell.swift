//
//  PreferencesCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class PreferencesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var Subheading: UILabel!
    @IBOutlet weak var Heading: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        // 1. CALL THE DESIGN FUNCTION
        setupCardDesign()
    }
    
    func setupCardDesign() {
            // Corner Radius
            self.layer.cornerRadius = 15
            self.layer.cornerCurve = .continuous // iOS Modern "smooth" corners
            
            // Background Color (Ensure it's white, or the shadow won't look right)
            self.backgroundColor = .white
            
            // Drop Shadow
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOpacity = 0.15  // 0.0 to 1.0 (0.15 is subtle and nice)
            self.layer.shadowOffset = CGSize(width: 0, height: 0) // Vertical shift
            self.layer.shadowRadius = 6 // How blurry the shadow is
            
            // CRITICAL: This must be false for shadows to appear outside the bounds
            self.layer.masksToBounds = false
    }

    
    
    func configureCell(with item : PreferenceItem) {
        Heading.text = item.title
        Subheading.text = item.subheading
        
    }
}
