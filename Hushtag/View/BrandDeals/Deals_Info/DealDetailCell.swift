import UIKit

final class DealDetailCell: UICollectionViewListCell {

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .secondaryLabel

        valueLabel.font = .systemFont(ofSize: 14, weight: .regular)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 1

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .secondaryLabel

        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)

        let margins = contentView.layoutMarginsGuide

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            iconView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 2),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
            titleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: iconView.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ])

        // separator aligned with text block
        separatorLayoutGuide.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
    }

    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value

        let symbolName: String
        switch title {
        case "Deadline":     symbolName = "calendar"
        case "Payment":      symbolName = "checkmark.square"
        case "Gmail":        symbolName = "envelope"
        case "Phone number": symbolName = "phone"
        default:             symbolName = "circle"
        }

        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        iconView.image = UIImage(systemName: symbolName, withConfiguration: config)
    }
}
