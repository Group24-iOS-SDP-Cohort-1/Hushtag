import UIKit

class SuggestedForYou: UIView {
    
    let trendingLabel = UILabel()
    let navigation = UIButton()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let hashtagLabel1 = UILabel()
    let hashtagLabel2 = UILabel()
    
    var onTapNavigation: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCard()
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCard()
        setupUI()
        setupActions()
    }

    convenience init(
        trending: String,
        title: String,
        description: String,
        hashtag1: String,
        hashtag2: String
    ) {
        self.init(frame: .zero)
        configure(trending: trending, title: title, description: description, hashtag1: hashtag1, hashtag2: hashtag2)
    }

    func configure(
        trending: String,
        title: String,
        description: String,
        hashtag1: String,
        hashtag2: String
    ) {
        trendingLabel.text = "Trending in \(trending)"
        titleLabel.text = title
        descriptionLabel.text = description
        hashtagLabel1.text = hashtag1
        hashtagLabel2.text = hashtag2
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
   
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        trendingLabel.font = .systemFont(ofSize: 14)
        trendingLabel.textColor = .accent
        
        navigation.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        navigation.tintColor = .accent
        
        let topRow = UIStackView(arrangedSubviews: [trendingLabel, spacer, navigation])
        topRow.alignment = .center
        topRow.axis = .horizontal
        topRow.distribution = .fill
        
        titleLabel.font = .systemFont(ofSize: 20)
        titleLabel.numberOfLines = 0
        
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 0
        
        hashtagLabel1.font = .systemFont(ofSize: 14)
        hashtagLabel1.textColor = .accent
        hashtagLabel2.font = .systemFont(ofSize: 14)
        hashtagLabel2.textColor = .accent
        
        hashtagLabel1.setContentHuggingPriority(.required, for: .horizontal)
        hashtagLabel2.setContentHuggingPriority(.required, for: .horizontal)
        
        let bottomSpacer = UIView()
        bottomSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let bottomRow = UIStackView(arrangedSubviews: [hashtagLabel1, hashtagLabel2, bottomSpacer])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .leading
        bottomRow.distribution = .fill
        bottomRow.spacing = 5
        
        let stack = UIStackView(arrangedSubviews: [topRow, titleLabel, descriptionLabel, bottomRow])
        stack.axis = .vertical
        stack.spacing = 10
        
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    private func setupActions() {
        navigation.addTarget(self, action: #selector(didTapNavigation), for: .touchUpInside)
    }
    
    @objc private func didTapNavigation() {
        onTapNavigation?()
    }
}
