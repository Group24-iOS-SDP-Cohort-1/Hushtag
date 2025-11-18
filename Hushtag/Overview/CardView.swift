import UIKit

class CardView: UIView {
    
    let timeLabel = UILabel()
    let dateLabel = UILabel()
    let titleLabel = UILabel()
    let platformLabel = UILabel()
    
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
        time: String,
        date: String,
        title: String,
        platform: String
    ) {
        self.init(frame: .zero)
        configure(time: time, date: date, title: title, platform: platform)
    }

    func configure(
        time: String,
        date: String,
        title: String,
        platform: String
    ) {
        timeLabel.text = time
        dateLabel.text = date
        titleLabel.text = title
        platformLabel.text = platform
        
        // Color coding
        switch platform.lowercased() {
                case "youtube":
                    platformLabel.textColor = .systemRed
                case "facebook":
                    platformLabel.textColor = .systemBlue
                case "instagram":
                    platformLabel.textColor = .systemPurple
                default:
                    platformLabel.textColor = .darkGray   // fallback
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
        // Time label
        timeLabel.font = .systemFont(ofSize: 14, weight: .regular)
        timeLabel.textColor = .darkGray
        
        // Date label
        dateLabel.font = .systemFont(ofSize: 14, weight: .regular)
        dateLabel.textAlignment = .right
        dateLabel.textColor = .darkGray
        
        let topRow = UIStackView(arrangedSubviews: [timeLabel, dateLabel])
        topRow.axis = .horizontal
        topRow.distribution = .equalSpacing

        // Title
        titleLabel.font = .systemFont(ofSize: 18, weight: .regular)
        titleLabel.numberOfLines = 0

        // Platform
        platformLabel.font = UIFont.systemFont(ofSize: 14)
        platformLabel.textColor = .systemRed

        let stack = UIStackView(arrangedSubviews: [topRow, titleLabel, platformLabel])
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
