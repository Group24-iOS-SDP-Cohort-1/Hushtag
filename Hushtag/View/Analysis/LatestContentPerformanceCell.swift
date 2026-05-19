import UIKit

class LatestContentPerformanceCell: UICollectionViewCell {
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var publishedLabel: UILabel!
    @IBOutlet var likesLabel: UILabel!
    @IBOutlet var viewsLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        thumbnailImageView.layer.cornerRadius = 10
        thumbnailImageView.clipsToBounds = true
        applyLiquidGlassEffect()
    }

    func configure(with data: LatestContent) {
        titleLabel.text = data.title
        publishedLabel.text = "\(data.published_at.monthAndYear())"
        likesLabel.text = "\(data.likes)"
        viewsLabel.text = "\(data.views)"
        durationLabel.text = "\(data.duration_seconds) s"
        thumbnailImageView.loadImage(from: data.thumbnail)
    }
}
