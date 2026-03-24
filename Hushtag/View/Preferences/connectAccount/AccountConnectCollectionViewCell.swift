import UIKit

class AccountConnectCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var subheadingLabel: UILabel!
    
    @IBOutlet weak var youtubeOutlet: UIButton!
    
    weak var delegate: PreferenceCardSelectionDelegate?
    
    var cardIndex: Int = -1
    
    var isConnected: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 8.0
    }
    
    
    func updateButtonAppearance(_ button: UIButton, isSelected: Bool) {
        if isSelected {
            button.backgroundColor = UIColor.accent
            button.setTitleColor(.white, for: .normal)
            button.tintColor = .white
        } else {
            button.backgroundColor = .clear
            button.setTitleColor(.accent, for: .normal)
            button.tintColor = .accent
        }
    }
    
    private func notifyCompletionIfNeeded() {
        
        let completed = isConnected
        delegate?.preferenceCard(at: cardIndex, didChangeCompletion: completed)
    }
    
    @IBAction func youtubeAction(_ sender: Any) {
        guard !isConnected else { return }
        //print("Youtube tapped")
        //delegate1?.didTapConnectYouTube(from: self)
        
    }
    
}
