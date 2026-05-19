import UIKit

class RevenueSourceCell: UICollectionViewCell {
    @IBOutlet var sfSymbol: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        applyLiquidGlassEffect()
    }

    func configure(metric: RevenueType, data: Double) {
        var title = ""
        var sf = ""

        switch metric {
        case .ads:
            title = "Estimated Ad Revenue"
            sf = "play.rectangle.fill"

        case .paidContent:
            title = "From Paid Content"
            sf = "hand.thumbsup.fill"

        case .ypp:
            title = "Creator's Share from YPP"
            sf = "person.2.fill"

        case .collaboration:
            title = "Collaboration Revenue"
            sf = "briefcase.fill"
        }

        nameLabel.numberOfLines = 0
        nameLabel.text = title
        amountLabel.text = "Rs. \(data)"
        sfSymbol.image = UIImage(systemName: sf)
    }
}
