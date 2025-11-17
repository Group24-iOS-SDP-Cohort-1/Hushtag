import UIKit

class CardView: UIView {
    
    let timeLabel = UILabel()
    let dateLabel = UILabel()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCard()
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCard()
        setupUI()
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
        // --- Line 1: Time + Date ---
        timeLabel.text = "10:30"
        timeLabel.font = .systemFont(ofSize: 14, weight: .regular)
        timeLabel.textColor = .darkGray

        dateLabel.text = "Today"
        dateLabel.font = .systemFont(ofSize: 14, weight: .regular)
        dateLabel.textAlignment = .right
        dateLabel.textColor = .darkGray
        
        let topRow = UIStackView(arrangedSubviews: [timeLabel, dateLabel])
        topRow.axis = .horizontal
        topRow.distribution = .equalSpacing

        // --- Line 2: Title ---
        titleLabel.text = "Makeup tutorial for festive season"
        titleLabel.font = .systemFont(ofSize: 18, weight: .regular)
        titleLabel.numberOfLines = 0

        // --- Line 3: Description ---
        descriptionLabel.text = "YouTube"
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .systemRed

        // --- Main vertical stack ---
        let stack = UIStackView(arrangedSubviews: [topRow, titleLabel, descriptionLabel])
        stack.axis = .vertical
        stack.spacing = 8
        
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
