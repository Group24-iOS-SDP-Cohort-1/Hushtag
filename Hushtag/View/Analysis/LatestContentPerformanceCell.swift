import UIKit

class LatestContentPerformanceCell: UICollectionViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var publishedLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!

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
