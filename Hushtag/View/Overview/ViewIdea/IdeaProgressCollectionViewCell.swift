import UIKit

class IdeaProgressCollectionViewCell: UICollectionViewCell {
    @IBOutlet var view: UIView!

    @IBOutlet var progressBarContainer: UIView!

    @IBOutlet var viewYourDraft: UIButton!

    private var milestones = ["Script", "Title", "Description"]
    private var currentMilestone: Int = -1
    var onButtonTapped: (() -> Void)?

    /// Replace these properties at the top
    private let trackView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let progressView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.accent
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    /// Add this new property alongside milestoneDots/milestoneLabels
    private var milestoneCheckmarks: [UIImageView] = []

    private let dotSize: CGFloat = 26
    private let trackHeight: CGFloat = 3
    private let horizontalInset: CGFloat = 16
    // Update trackHeight

    private var milestoneDots: [UIView] = []
    private var milestoneLabels: [UILabel] = []
    private var progressWidthConstraint: NSLayoutConstraint?
    private var middleDotCenterXConstraints: [NSLayoutConstraint] = []
    private var lastContainerWidth: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        view.applyLiquidGlassEffect()
        progressBarContainer.backgroundColor = .clear

        setupProgressBar()
        setupButton()

        view.layer.cornerRadius = 16
        view.clipsToBounds = true

        // Button styling
        viewYourDraft.layer.cornerRadius = 20
        viewYourDraft.backgroundColor = UIColor.accent.withAlphaComponent(0.15)
        viewYourDraft.layer.borderWidth = 1
        viewYourDraft.layer.borderColor = UIColor.accent.withAlphaComponent(0.6).cgColor
        viewYourDraft.setTitleColor(UIColor.accent, for: .normal)
        viewYourDraft.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    }

    private func setupButton() {
        viewYourDraft.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    /// Replace setupProgressBar() entirely
    private func setupProgressBar() {
        progressBarContainer.addSubview(trackView)
        trackView.addSubview(progressView)

        NSLayoutConstraint.activate([
            // Track runs between dot centers, vertically centred in dot area
            trackView.centerYAnchor.constraint(equalTo: progressBarContainer.topAnchor, constant: dotSize / 2),
            trackView.leadingAnchor.constraint(
                equalTo: progressBarContainer.leadingAnchor,
                constant: horizontalInset + dotSize / 2
            ),
            trackView.trailingAnchor.constraint(
                equalTo: progressBarContainer.trailingAnchor,
                constant: -(horizontalInset + dotSize / 2)
            ),
            trackView.heightAnchor.constraint(equalToConstant: trackHeight),

            progressView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            progressView.topAnchor.constraint(equalTo: trackView.topAnchor),
            progressView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor)
        ])

        progressWidthConstraint = progressView.widthAnchor.constraint(
            equalTo: trackView.widthAnchor, multiplier: 0.001
        )
        progressWidthConstraint?.isActive = true

        for (index, milestone) in milestones.enumerated() {
            // Dot
            let dot = UIView()
            dot.layer.cornerRadius = dotSize / 2
            dot.layer.borderWidth = 2
            dot.layer.borderColor = UIColor.systemGray3.cgColor
            dot.backgroundColor = .clear
            dot.translatesAutoresizingMaskIntoConstraints = false
            progressBarContainer.addSubview(dot)
            milestoneDots.append(dot)

            // Checkmark inside dot
            let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
            let checkmark = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: config))
            checkmark.tintColor = .white
            checkmark.contentMode = .scaleAspectFit
            checkmark.translatesAutoresizingMaskIntoConstraints = false
            checkmark.alpha = 0
            dot.addSubview(checkmark)
            milestoneCheckmarks.append(checkmark)

            // Label
            let label = UILabel()
            label.text = milestone
            label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
            label.textColor = .systemGray
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            progressBarContainer.addSubview(label)
            milestoneLabels.append(label)

            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: dotSize),
                dot.heightAnchor.constraint(equalToConstant: dotSize),
                dot.topAnchor.constraint(equalTo: progressBarContainer.topAnchor),

                checkmark.centerXAnchor.constraint(equalTo: dot.centerXAnchor),
                checkmark.centerYAnchor.constraint(equalTo: dot.centerYAnchor),

                label.topAnchor.constraint(equalTo: dot.bottomAnchor, constant: 6),
                label.centerXAnchor.constraint(equalTo: dot.centerXAnchor),
                label.widthAnchor.constraint(equalToConstant: 80)
            ])

            switch index {
            case 0:
                dot.leadingAnchor.constraint(equalTo: progressBarContainer.leadingAnchor, constant: horizontalInset)
                    .isActive = true
            case milestones.count - 1:
                dot.trailingAnchor.constraint(equalTo: progressBarContainer.trailingAnchor, constant: -horizontalInset)
                    .isActive = true
            default:
                dot.centerXAnchor.constraint(equalTo: progressBarContainer.centerXAnchor).isActive = true
            }
        }
    }

    /// Replace layoutSubviews()
    override func layoutSubviews() {
        super.layoutSubviews()

        let width = progressBarContainer.bounds.width
        guard width > 0, width != lastContainerWidth else { return }
        lastContainerWidth = width

        for (i, constraint) in middleDotCenterXConstraints.enumerated() {
            let milestoneIndex = i + 1
            let fraction = CGFloat(milestoneIndex) / CGFloat(milestones.count - 1)
            let trackWidth = width - (horizontalInset * 2) - dotSize
            constraint.constant = horizontalInset + (dotSize / 2) + trackWidth * fraction
        }
    }

    @objc private func buttonTapped() {
        onButtonTapped?()
    }

    func configure(completedTypes: Set<String>, buttonTitle: String = "View Draft") {
        viewYourDraft.setTitle(buttonTitle, for: .normal)
        viewYourDraft.setTitleColor(.white, for: .normal)

        let typeOrder = ["script", "title", "description"]

        // Reorder: marked types first, then unmarked
        let reordered = typeOrder.filter { completedTypes.contains($0) }
            + typeOrder.filter { !completedTypes.contains($0) }

        // Update labels
        for (index, label) in milestoneLabels.enumerated() {
            guard index < reordered.count else { continue }
            label.text = reordered[index].capitalized
        }

        progressWidthConstraint?.isActive = false
        let completedCount = completedTypes.count
        let lastCompletedIndex = completedCount == 0 ? nil : completedCount - 1
        let fraction: CGFloat = lastCompletedIndex.map {
            CGFloat($0) / CGFloat(milestones.count - 1)
        } ?? 0.001

        progressWidthConstraint = progressView.widthAnchor.constraint(
            equalTo: trackView.widthAnchor,
            multiplier: max(fraction, 0.001)
        )
        progressWidthConstraint?.isActive = true

        for (index, dot) in milestoneDots.enumerated() {
            guard index < reordered.count else { continue }
            let type = reordered[index]
            let isActive = completedTypes.contains(type)

            UIView.animate(withDuration: 0.25) {
                dot.layer.borderColor = isActive ? UIColor.accent.cgColor : UIColor.systemGray3.cgColor
                dot.backgroundColor = isActive ? UIColor.accent : UIColor.systemGray5
                self.milestoneCheckmarks[index].alpha = isActive ? 1 : 0
                self.milestoneLabels[index].textColor = isActive ? UIColor.accent : .systemGray
                self.milestoneLabels[index].font = UIFont.systemFont(
                    ofSize: 11,
                    weight: isActive ? .semibold : .medium
                )
            }
        }

        setNeedsLayout()
    }
}
