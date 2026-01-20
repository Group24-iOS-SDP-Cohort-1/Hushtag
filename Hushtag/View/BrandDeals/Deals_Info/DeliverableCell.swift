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

        if let day = deliverable.deadline.day,
           let date = deliverable.deadline.date?.prefix(10) {
            subtitleLabel.text = "Due \(day) \(date)"
        }

        let purple = UIColor(
            red: 139/255,
            green: 92/255,
            blue: 246/255,
            alpha: 1
        )

        let imageName = deliverable.isCompleted
            ? "circle.inset.filled"
            : "circle"

        statusImageView.image = UIImage(systemName: imageName)
        statusImageView.tintColor = purple

        separatorView.isHidden = isLast
    }
}
