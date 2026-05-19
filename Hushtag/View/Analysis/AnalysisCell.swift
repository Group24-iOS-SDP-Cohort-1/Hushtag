import UIKit

class AnalysisCell: UICollectionViewCell {
    @IBOutlet var analysisValue: UILabel!
    @IBOutlet var analysisType: UILabel!
    @IBOutlet var changeLabel: UILabel!
    @IBOutlet var sfSymbol: UIImageView!

    ///
    override func awakeFromNib() {
        super.awakeFromNib()
        applyLiquidGlassEffect()
    }

    func configure(
        metric: AnalysisMetric,
        data: Int,
        audience: AudienceMetrics
    ) {
        analysisValue.text = "\(data.formattedCount())"
        var title: String!
        var change: String!
        switch metric {
        case .views:
            title = "Views"
            change = "\(audience.views_change)%"

        case .likes:
            title = "Likes"
            change = "\(audience.likes_change)%"

        case .watchTime:
            title = "Watch Time"
            change = "\(audience.watch_time_change)%"

        case .subscribers:
            title = "Subscribers"
            change = "\(audience.subscribers_change)"
        }

        analysisType.text = title

        changeLabel.text = change
        if change.contains("-") {
            changeLabel.textColor = .systemRed
            sfSymbol.image = UIImage(systemName: "arrowshape.down.circle.fill")
            sfSymbol.tintColor = .systemRed

            changeLabel.text = change.replacingOccurrences(of: "-", with: "")
        } else {
            changeLabel.textColor = .systemGreen
            sfSymbol.image = UIImage(systemName: "arrowshape.up.circle.fill")
            sfSymbol.tintColor = .systemGreen

            changeLabel.text = change
        }
    }
}
