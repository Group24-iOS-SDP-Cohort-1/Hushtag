//
//  IdeaProgressCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 24/03/26.
//

import UIKit

class IdeaProgressCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var view: UIView!

    @IBOutlet weak var progressBarContainer: UIView!

    @IBOutlet weak var viewYourDraft: UIButton!

    private let milestones = ["Script", "Title", "Description"]
        private var currentMilestone: Int = -1
        var onButtonTapped: (() -> Void)?

    // Replace these properties at the top
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

    // Add this new property alongside milestoneDots/milestoneLabels
    private var milestoneCheckmarks: [UIImageView] = []

    private let dotSize: CGFloat = 20
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

    // Replace setupProgressBar() entirely
    private func setupProgressBar() {
        progressBarContainer.addSubview(trackView)
        trackView.addSubview(progressView)

        NSLayoutConstraint.activate([
            // Track runs between dot centers, vertically centred in dot area
            trackView.centerYAnchor.constraint(equalTo: progressBarContainer.topAnchor, constant: dotSize / 2),
            trackView.leadingAnchor.constraint(equalTo: progressBarContainer.leadingAnchor, constant: horizontalInset + dotSize / 2),
            trackView.trailingAnchor.constraint(equalTo: progressBarContainer.trailingAnchor, constant: -(horizontalInset + dotSize / 2)),
            trackView.heightAnchor.constraint(equalToConstant: trackHeight),

            progressView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            progressView.topAnchor.constraint(equalTo: trackView.topAnchor),
            progressView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),
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
            let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
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
                checkmark.widthAnchor.constraint(equalToConstant: 14),
                checkmark.heightAnchor.constraint(equalToConstant: 14),

                label.topAnchor.constraint(equalTo: dot.bottomAnchor, constant: 8),
                label.centerXAnchor.constraint(equalTo: dot.centerXAnchor),
                label.widthAnchor.constraint(equalToConstant: 80),
            ])

            switch index {
            case 0:
                dot.leadingAnchor.constraint(equalTo: progressBarContainer.leadingAnchor, constant: horizontalInset).isActive = true
            case milestones.count - 1:
                dot.trailingAnchor.constraint(equalTo: progressBarContainer.trailingAnchor, constant: -horizontalInset).isActive = true
            default:
                let centerX = dot.centerXAnchor.constraint(equalTo: progressBarContainer.leadingAnchor, constant: 0)
                centerX.isActive = true
                middleDotCenterXConstraints.append(centerX)
            }
        }
    }
    // Replace layoutSubviews()
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

        func configure(currentMilestone: Int, buttonTitle: String = "View Draft") {
            self.currentMilestone = max(-1, min(currentMilestone, milestones.count - 1))

            viewYourDraft.setTitle(buttonTitle, for: .normal)
            viewYourDraft.setTitleColor(.white, for: .normal)

            // Update progress bar width
            progressWidthConstraint?.isActive = false
            let fraction: CGFloat
            if self.currentMilestone < 0 {
                fraction = 0.001  // empty bar
            } else {
                fraction = CGFloat(self.currentMilestone) / CGFloat(milestones.count - 1)
            }
            progressWidthConstraint = progressView.widthAnchor.constraint(
                equalTo: trackView.widthAnchor,
                multiplier: max(fraction, 0.001)
            )
            progressWidthConstraint?.isActive = true

            // Update dots
            // Replace the dots update block inside configure()
            for (index, dot) in milestoneDots.enumerated() {
                let isDone = index < self.currentMilestone
                let isCurrent = index == self.currentMilestone

                // In configure() replace the animate block:

                UIView.animate(withDuration: 0.25) {
                    let isActive = index <= self.currentMilestone  // ← single condition, no isDone/isCurrent split

                    dot.layer.borderColor = isActive ? UIColor.accent.cgColor : UIColor.systemGray3.cgColor
                    dot.backgroundColor = isActive ? UIColor.accent : .clear
                    dot.transform = .identity  // ← remove all scaling, every dot same size
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
