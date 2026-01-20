import UIKit

final class DetailsCell: UICollectionViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!

    // MARK: - Private
    private var minHeightConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Icon tint
        iconImageView.tintColor = UIColor(
            red: 139/255,
            green: 92/255,
            blue: 246/255,
            alpha: 1
        )

        // Separator color
        separatorView.backgroundColor = UIColor.white.withAlphaComponent(0.15)

        // ✅ FORCE EQUAL ROW HEIGHT (CODE-ONLY)
        setupMinimumHeight()
    }

    private func setupMinimumHeight() {
        // Prevent duplicate constraint on reuse
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
