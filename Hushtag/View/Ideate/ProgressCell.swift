import UIKit

class ProgressCell: UIView {

    private let milestones = ["Script", "Title", "Description"]
    private var currentMilestone: Int = -1

    private let dotSize: CGFloat = 26
    private let trackHeight: CGFloat = 3
    private let horizontalInset: CGFloat = 16

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

    private var milestoneDots: [UIView] = []
    private var milestoneCheckmarks: [UIImageView] = []
    private var milestoneLabels: [UILabel] = []
    private var progressWidthConstraint: NSLayoutConstraint?
    private var middleDotCenterXConstraints: [NSLayoutConstraint] = []
    private var lastWidth: CGFloat = 0

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .clear

        addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        setupProgressBar()
    }

    private func setupProgressBar() {
        containerView.addSubview(trackView)
        trackView.addSubview(progressView)

        NSLayoutConstraint.activate([
            trackView.centerYAnchor.constraint(equalTo: containerView.topAnchor, constant: dotSize / 2),
            trackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: horizontalInset + dotSize / 2),
            trackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -(horizontalInset + dotSize / 2)),
            trackView.heightAnchor.constraint(equalToConstant: trackHeight),

            progressView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            progressView.topAnchor.constraint(equalTo: trackView.topAnchor),
            progressView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),
        ])

        progressWidthConstraint = progressView.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: 0.001)
        progressWidthConstraint?.isActive = true

        for (index, milestone) in milestones.enumerated() {

            let dot = UIView()
            dot.layer.cornerRadius = dotSize / 2
            dot.layer.borderWidth = 2
            dot.layer.borderColor = UIColor.systemGray3.cgColor
            dot.backgroundColor = .clear
            dot.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(dot)
            milestoneDots.append(dot)

            let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
            let checkmark = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: config))
            checkmark.tintColor = .white
            checkmark.translatesAutoresizingMaskIntoConstraints = false
            checkmark.alpha = 0
            dot.addSubview(checkmark)
            milestoneCheckmarks.append(checkmark)

            let label = UILabel()
            label.text = milestone
            label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
            label.textColor = .systemGray
            label.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(label)
            milestoneLabels.append(label)

            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: dotSize),
                dot.heightAnchor.constraint(equalToConstant: dotSize),
                dot.topAnchor.constraint(equalTo: containerView.topAnchor),

                checkmark.centerXAnchor.constraint(equalTo: dot.centerXAnchor),
                checkmark.centerYAnchor.constraint(equalTo: dot.centerYAnchor),

                label.topAnchor.constraint(equalTo: dot.bottomAnchor, constant: 6),
                label.centerXAnchor.constraint(equalTo: dot.centerXAnchor),
            ])

            switch index {
            case 0:
                dot.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: horizontalInset).isActive = true
            case milestones.count - 1:
                dot.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -horizontalInset).isActive = true
            default:
                let centerX = dot.centerXAnchor.constraint(equalTo: containerView.leadingAnchor)
                centerX.isActive = true
                middleDotCenterXConstraints.append(centerX)
            }
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        let width = containerView.bounds.width
        guard width > 0, width != lastWidth else { return }
        lastWidth = width

        for (i, constraint) in middleDotCenterXConstraints.enumerated() {
            let milestoneIndex = i + 1
            let fraction = CGFloat(milestoneIndex) / CGFloat(milestones.count - 1)
            let trackWidth = width - (horizontalInset * 2) - dotSize
            constraint.constant = horizontalInset + (dotSize / 2) + trackWidth * fraction
        }
    }

    // MARK: - Configure

    func configure(currentMilestone: Int) {
        self.currentMilestone = max(-1, min(currentMilestone, milestones.count - 1))

        progressWidthConstraint?.isActive = false
        let fraction: CGFloat = self.currentMilestone < 0
            ? 0.001
            : CGFloat(self.currentMilestone) / CGFloat(milestones.count - 1)

        progressWidthConstraint = progressView.widthAnchor.constraint(
            equalTo: trackView.widthAnchor,
            multiplier: max(fraction, 0.001)
        )
        progressWidthConstraint?.isActive = true

        for (index, dot) in milestoneDots.enumerated() {
            let isActive = index <= self.currentMilestone
            UIView.animate(withDuration: 0.25) {
                dot.layer.borderColor = isActive ? UIColor.accent.cgColor : UIColor.systemGray3.cgColor
                dot.backgroundColor = isActive ? UIColor.accent : .clear
                self.milestoneCheckmarks[index].alpha = isActive ? 1 : 0
                self.milestoneLabels[index].textColor = isActive ? UIColor.accent : .systemGray
            }
        }

        setNeedsLayout()
    }
}
