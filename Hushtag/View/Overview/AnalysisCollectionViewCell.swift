import UIKit

class AnalysisCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var ValueLabel: UILabel!
    @IBOutlet weak var CategoryLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCard()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCard()
    }
    private func setupCard() {
        backgroundColor = .white
//        contentView.backgroundColor = .white
        layer.cornerRadius = 15
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.10
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.masksToBounds = false
//        layer.shadowRadius = 3
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 15

    }
}
