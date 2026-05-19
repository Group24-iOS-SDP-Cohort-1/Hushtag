import UIKit

final class DetailsCell: UICollectionViewCell {
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var separatorView: UIView!

    private var minHeightConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        iconImageView.tintColor = .accent
        separatorView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        setupMinimumHeight()
    }

    private func setupMinimumHeight() {
        if minHeightConstraint == nil {
            let constraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 56)
            constraint.priority = .required
            constraint.isActive = true
            minHeightConstraint = constraint
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        separatorView.isHidden = false
    }

    func configure(iconName: String, text: String, isLast: Bool) {
        iconImageView.image = UIImage(systemName: iconName)
        valueLabel.text = text
        separatorView.isHidden = isLast
    }
}
