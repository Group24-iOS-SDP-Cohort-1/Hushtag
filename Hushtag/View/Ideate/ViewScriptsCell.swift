import UIKit

class ViewScriptsCell: UICollectionViewCell {
    
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var readMoreButton: UIButton!
    
    private var fullText: String = ""
    private var isExpanded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with text: String) {
        content.numberOfLines = 8
        content.text = text
    }
    
    func configureTitle(with text: String) {
        titleLabel.text = text
    }
    
    private func collapsedText(_ text: String) -> NSAttributedString {
        let readMore = "... Read more"
        
        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [.foregroundColor: UIColor.label]
        )
        
        let readMoreAttr = NSAttributedString(
            string: readMore,
            attributes: [.foregroundColor: UIColor.tintColor]
        )
        
        attributed.append(readMoreAttr)
        return attributed
    }
    
    @objc private func handleTap() {
        guard !isExpanded else { return }
        
        isExpanded = true
        content.numberOfLines = 0
        content.text = fullText
        
        if let collectionView = superview as? UICollectionView {
            collectionView.performBatchUpdates(nil)
        }
    }
}
