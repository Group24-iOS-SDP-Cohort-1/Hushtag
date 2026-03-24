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

        private let trackView: UIView = {
            let v = UIView()
            v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
            v.layer.cornerRadius = 4
            v.translatesAutoresizingMaskIntoConstraints = false
            return v
        }()

        private let progressView: UIView = {
            let v = UIView()
            v.backgroundColor = UIColor.accent
            v.layer.cornerRadius = 4
            v.translatesAutoresizingMaskIntoConstraints = false
            return v
        }()

        private var milestoneDots: [UIView] = []
        private var milestoneLabels: [UILabel] = []
        private var progressWidthConstraint: NSLayoutConstraint?
        private var middleDotCenterXConstraints: [NSLayoutConstraint] = []
        private var lastContainerWidth: CGFloat = 0

        override func awakeFromNib() {
            super.awakeFromNib()

            backgroundColor = .clear
            contentView.backgroundColor = .clear
            view.backgroundColor = .clear
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

        private func setupProgressBar() {
            let dotSize: CGFloat = 16
            let trackHeight: CGFloat = 8
            let trackTopOffset: CGFloat = (dotSize - trackHeight) / 2
            let horizontalInset: CGFloat = 32

            progressBarContainer.addSubview(trackView)
            trackView.addSubview(progressView)

            NSLayoutConstraint.activate([
                trackView.topAnchor.constraint(equalTo: progressBarContainer.topAnchor, constant: trackTopOffset),
                trackView.leadingAnchor.constraint(equalTo: progressBarContainer.leadingAnchor, constant: horizontalInset),
                trackView.trailingAnchor.constraint(equalTo: progressBarContainer.trailingAnchor, constant: -horizontalInset),
                trackView.heightAnchor.constraint(equalToConstant: trackHeight),

                progressView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
                progressView.topAnchor.constraint(equalTo: trackView.topAnchor),
                progressView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),
            ])

            // Start with empty bar (milestone = -1)
            progressWidthConstraint = progressView.widthAnchor.constraint(
                equalTo: trackView.widthAnchor,
                multiplier: 0.001
            )
            progressWidthConstraint?.isActive = true

            for (index, milestone) in milestones.enumerated() {

                let dot = UIView()
                dot.layer.cornerRadius = dotSize / 2
                dot.layer.borderWidth = 2
                dot.translatesAutoresizingMaskIntoConstraints = false
                // All empty on init
                dot.backgroundColor = .clear
                dot.layer.borderColor = UIColor.systemGray3.cgColor

                progressBarContainer.addSubview(dot)
                milestoneDots.append(dot)

                let label = UILabel()
                label.text = milestone
                label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
                label.textColor = .systemGray
                label.textAlignment = .center
                label.translatesAutoresizingMaskIntoConstraints = false
                progressBarContainer.addSubview(label)
                milestoneLabels.append(label)

                NSLayoutConstraint.activate([
                    dot.widthAnchor.constraint(equalToConstant: dotSize),
                    dot.heightAnchor.constraint(equalToConstant: dotSize),
                    dot.topAnchor.constraint(equalTo: progressBarContainer.topAnchor),
                    label.topAnchor.constraint(equalTo: dot.bottomAnchor, constant: 6),
                    label.centerXAnchor.constraint(equalTo: dot.centerXAnchor),
                    label.widthAnchor.constraint(equalToConstant: 64),
                ])

                switch index {
                case 0:
                    dot.centerXAnchor.constraint(equalTo: trackView.leadingAnchor).isActive = true
                case milestones.count - 1:
                    dot.centerXAnchor.constraint(equalTo: trackView.trailingAnchor).isActive = true
                default:
                    let centerX = dot.centerXAnchor.constraint(
                        equalTo: progressBarContainer.leadingAnchor,
                        constant: 0
                    )
                    centerX.isActive = true
                    middleDotCenterXConstraints.append(centerX)
                }
            }
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            let width = progressBarContainer.bounds.width
            guard width > 0, width != lastContainerWidth else { return }
            lastContainerWidth = width

            for (i, constraint) in middleDotCenterXConstraints.enumerated() {
                let milestoneIndex = i + 1
                let fraction = CGFloat(milestoneIndex) / CGFloat(milestones.count - 1)
                let trackInset: CGFloat = 32
                constraint.constant = trackInset + (width - trackInset * 2) * fraction
            }
        }

        @objc private func buttonTapped() {
            onButtonTapped?()
        }

        func configure(currentMilestone: Int, buttonTitle: String = "View Your Draft") {
            self.currentMilestone = max(-1, min(currentMilestone, milestones.count - 1))

            viewYourDraft.setAttributedTitle(nil, for: .normal)
            viewYourDraft.setTitle(buttonTitle, for: .normal)

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
            for (index, dot) in milestoneDots.enumerated() {
                if index < self.currentMilestone {
                    // Completed — filled solid, normal size
                    dot.backgroundColor = UIColor.accent
                    dot.layer.borderColor = UIColor.accent.cgColor
                    dot.transform = .identity
                } else if index == self.currentMilestone {
                    // Current — filled + slightly larger to stand out
                    dot.backgroundColor = UIColor.accent
                    dot.layer.borderColor = UIColor.accent.cgColor
                    dot.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
                } else {
                    // Future — empty
                    dot.backgroundColor = .clear
                    dot.layer.borderColor = UIColor.systemGray3.cgColor
                    dot.transform = .identity
                }

                milestoneLabels[index].font = UIFont.systemFont(
                    ofSize: 10,
                    weight: index == self.currentMilestone ? .semibold : .regular
                )
                milestoneLabels[index].textColor = index <= self.currentMilestone ? UIColor.accent : .systemGray
            }

            setNeedsLayout()
        }

}
