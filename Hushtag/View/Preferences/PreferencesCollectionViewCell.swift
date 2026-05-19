import UIKit

class PreferencesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var Subheading: UILabel!
    @IBOutlet weak var Heading: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardDesign()
    }

    func setupCardDesign() {

        self.layer.cornerRadius = 15
        self.layer.cornerCurve = .continuous

        self.backgroundColor = .white

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.15
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 6

        self.layer.masksToBounds = false
    }

}
