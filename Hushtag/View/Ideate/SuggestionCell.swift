import UIKit

class SuggestionCell: UIView {
    @IBOutlet var generateButton: UIButton!

    override func awakeFromNib() {
        generateButton.layer.borderWidth = 1
        generateButton.layer.borderColor = UIColor.accent.cgColor
    }
}
