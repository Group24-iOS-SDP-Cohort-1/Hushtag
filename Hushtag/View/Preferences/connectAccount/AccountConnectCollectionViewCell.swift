//
//  TestCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit
import SafariServices


class AccountConnectCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var subheadingLabel: UILabel!
    
    
    @IBOutlet weak var youtubeOutlet: UIButton!
    
    
    weak var delegate: PreferenceCardSelectionDelegate?
    weak var delegate1: YouTubeConnectDelegate?

    var cardIndex: Int = -1
    
    var isConnected: Bool = false

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupCardDesign()
        
        setupInitialButtonStyle(youtubeOutlet)
        
    }
    
    
    func setupCardDesign() {
        contentView.applyLiquidGlassEffect()
    }
    
    
    func configureCell(with item: PreferenceItem){
        headingLabel.text = item.title
        subheadingLabel.text = item.subheading
        
        updateButtonAppearance(youtubeOutlet, isSelected: isConnected)
    }
    
    func setupInitialButtonStyle(_ button: UIButton) {
        button.backgroundColor = .clear
        button.layer.borderColor = UIColor.accent.cgColor
        button.layer.borderWidth = 1.0 // Ensure width is set so border is visible
        button.layer.cornerRadius = 8.0 // Optional: Makes buttons look better
    }
    
    
    func updateButtonAppearance(_ button: UIButton, isSelected: Bool) {
        if isSelected {
            // State is Connected -> Filled Style
            button.backgroundColor = UIColor.accent
            // Optional: Change text/icon color to white for better contrast
            button.setTitleColor(.white, for: .normal)
            button.tintColor = .white
        } else {
            // State is Disconnected -> Border Style
            button.backgroundColor = .clear
            button.setTitleColor(.accent, for: .normal)
            button.tintColor = .accent
        }
    }
    
    private func notifyCompletionIfNeeded() {
            // sum selected items across sections
            
        let completed = isConnected
            delegate?.preferenceCard(at: cardIndex, didChangeCompletion: completed)
        }

    @IBAction func youtubeAction(_ sender: Any) {
        guard !isConnected else { return }
        delegate1?.didTapConnectYouTube(from: self)

    }
    
    
    
    
}
