import UIKit

class PreferencesCollectionViewCell: UICollectionViewCell {
    @IBOutlet var Subheading: UILabel!
    @IBOutlet var Heading: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardDesign()
    }

    func setupCardDesign() {
        layer.cornerRadius = 15
        layer.cornerCurve = .continuous

        backgroundColor = .white

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 6

        layer.masksToBounds = false
    }
}
