import UIKit

final class DeliverableCell: UICollectionViewCell {

    static let reuseId = "DeliverableCell"

    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        separatorView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
    }

    func configure(with deliverable: Deliverable, isLast: Bool) {

        titleLabel.text = deliverable.name

        let day = deliverable.deadline.dayOnly()
                let date = deliverable.deadline.dateAndMonth()
                subtitleLabel.text = "Due \(day), \(date)"

        let imageName = deliverable.isCompleted
            ? "circle.inset.filled"
            : "circle"

        statusImageView.image = UIImage(systemName: imageName)
        statusImageView.tintColor = .accent

        separatorView.isHidden = isLast
    }
}
