import UIKit

protocol PremiumIdeaCellDelegate: AnyObject {
    func didToggleLike(for cell: PremiumIdeaCell)
}

class PremiumIdeaCell: UICollectionViewCell {
    static let identifier = "PremiumIdeaCell"
    weak var delegate: PremiumIdeaCellDelegate?

    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        button.setImage(UIImage(systemName: "bookmark", withConfiguration: config), for: .normal)
        button.tintColor = .secondaryLabel
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.applyLiquidGlassEffect()

        containerView.addSubview(bookmarkButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)

        bookmarkButton.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: bookmarkButton.leadingAnchor, constant: -12),

            bookmarkButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            bookmarkButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 32),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 32),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18),
            subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -18)
        ])
    }

    @objc private func bookmarkTapped() {
        delegate?.didToggleLike(for: self)
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
                self.containerView.alpha = self.isHighlighted ? 0.7 : 1.0
            })
        }
    }

    func configure(with analyticsIdea: AnalyticsIdea, isSaved: Bool) {
        titleLabel.text = analyticsIdea.title
        subtitleLabel.text = analyticsIdea.hook

        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        bookmarkButton.setImage(
            UIImage(systemName: isSaved ? "bookmark.fill" : "bookmark", withConfiguration: config),
            for: .normal
        )
        bookmarkButton.tintColor = isSaved ? .accent : .secondaryLabel
    }

    func configure(with idea: Idea) {
        titleLabel.text = idea.title
        subtitleLabel.text = idea.description

        let isSaved = idea.liked == true
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        bookmarkButton.setImage(
            UIImage(systemName: isSaved ? "bookmark.fill" : "bookmark", withConfiguration: config),
            for: .normal
        )
        bookmarkButton.tintColor = isSaved ? .accent : .secondaryLabel
    }
}
