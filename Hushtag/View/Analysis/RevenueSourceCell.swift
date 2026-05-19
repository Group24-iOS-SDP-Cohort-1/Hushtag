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
        var sfSymbolName = ""

        switch metric {
        case .ads:
            title = "Estimated Ad Revenue"
            sfSymbolName = "play.rectangle.fill"

        case .paidContent:
            title = "From Paid Content"
            sfSymbolName = "hand.thumbsup.fill"

        case .ypp:
            title = "Creator's Share from YPP"
            sfSymbolName = "person.2.fill"

        case .collaboration:
            title = "Collaboration Revenue"
            sfSymbolName = "briefcase.fill"
        }

        nameLabel.numberOfLines = 0
        nameLabel.text = title
        amountLabel.text = "Rs. \(data)"
        sfSymbol.image = UIImage(systemName: sfSymbolName)
    }
}
