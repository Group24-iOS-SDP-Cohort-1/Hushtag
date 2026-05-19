import UIKit

class OptionsCollectionViewCell: UICollectionViewCell {
    @IBOutlet var buttonLabel: UILabel!

    let customPurple = UIColor(red: 139 / 255, green: 92 / 255, blue: 246 / 255, alpha: 1)

    override func awakeFromNib() {
        super.awakeFromNib()

        setupStyle()
    }

    func setupStyle() {
        layer.cornerRadius = 18
        layer.borderWidth = 1
        layer.borderColor = customPurple.cgColor
        buttonLabel.textColor = customPurple
        contentView.applyLiquidGlassEffect()
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderColor = customPurple.cgColor
                backgroundColor = customPurple
                buttonLabel.textColor = .white

                if let basicText = buttonLabel.text {
                    buttonLabel.attributedText = .symbolPrefixedText(
                        symbol: "xmark",
                        text: basicText,
                        font: buttonLabel.font,
                        color: buttonLabel.textColor
                    )
                }
            } else {
                layer.borderColor = customPurple.cgColor
                backgroundColor = .clear
                buttonLabel.textColor = customPurple

                buttonLabel.removeSymbolPrefix()
            }
        }
    }

    func configureCell(with buttonName: String) {
        buttonLabel.text = buttonName
    }
}

extension NSAttributedString {
    static func symbolPrefixedText(symbol: String, text: String, font: UIFont, color: UIColor) -> NSAttributedString {
        let config = UIImage.SymbolConfiguration(pointSize: font.pointSize, weight: .regular)
        let image = UIImage(systemName: symbol, withConfiguration: config)?
            .withRenderingMode(.alwaysTemplate)

        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(
            x: 0,
            y: (font.capHeight - font.pointSize) / 2,
            width: font.pointSize,
            height: font.pointSize
        )

        let symbolString = NSAttributedString(attachment: attachment)

        let textString = NSAttributedString(
            string: " " + text,
            attributes: [.font: font, .foregroundColor: color]
        )

        let combined = NSMutableAttributedString()
        combined.append(symbolString)
        combined.append(textString)

        return combined
    }
}

extension UILabel {
    func removeSymbolPrefix() {
        guard let attr = attributedText else { return }

        let full = attr.string

        let trimmed = full.trimmingCharacters(in: .whitespaces)

        attributedText = nil
        text = trimmed
    }
}
