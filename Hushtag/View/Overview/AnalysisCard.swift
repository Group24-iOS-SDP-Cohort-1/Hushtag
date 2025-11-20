import UIKit

class AnalysisCard: UIView {
    
    let valueLabel = UILabel()
    let sfLabel = UILabel()
    let categoryLabel = UILabel()
    
    var onTap: (() -> Void)?   // callback

    private func setupView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCard))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
        
    @objc private func didTapCard() {
        onTap?()   // Trigger callback
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCard()
        setupUI()
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCard()
        setupUI()
        setupView()
    }

    convenience init(
        value: String,
        sf: String,
        category: String
    ) {
        self.init(frame: .zero)
        configure(value: value, sf: sf, category: category)
    }

    func configure(
        value: String,
        sf: String,
        category: String
    ) {
        valueLabel.text = value

        categoryLabel.text = category
        
        switch category.lowercased() {
                case "youtube":
            categoryLabel.textColor = .systemRed
                case "facebook":
            categoryLabel.textColor = .systemBlue
                case "instagram":
            categoryLabel.textColor = .systemPurple
                default:
            categoryLabel.textColor = .darkGray   // fallback
                }
        
        switch sf.lowercased() {
        case "increase":
            let attachment = NSTextAttachment()
            attachment.image = UIImage(systemName: "arrow.up.circle.fill")?
                .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
            attachment.bounds = CGRect(x: 0, y: -2, width: 20, height: 20)
            sfLabel.attributedText = NSAttributedString(attachment: attachment)

        case "decrease":
            let attachment = NSTextAttachment()
            attachment.image = UIImage(systemName: "arrow.down.circle.fill")?
                .withTintColor(.systemRed, renderingMode: .alwaysOriginal)
            attachment.bounds = CGRect(x: 0, y: -2, width: 20, height: 20)
            sfLabel.attributedText = NSAttributedString(attachment: attachment)

        default:
            sfLabel.text = ""             // fallback
            sfLabel.textColor = .darkGray
        }

    }

    private func setupCard() {
        backgroundColor = .white
        layer.cornerRadius = 15
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.10
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6
    }

    private func setupUI() {
        // Value label
        valueLabel.font = .systemFont(ofSize: 24, weight: .medium)
        
        let topRow = UIStackView(arrangedSubviews: [valueLabel, sfLabel])
        topRow.axis = .horizontal
        topRow.alignment = .center

        // Category label
        categoryLabel.font = UIFont.systemFont(ofSize: 14)

        let stack = UIStackView(arrangedSubviews: [topRow, categoryLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}
