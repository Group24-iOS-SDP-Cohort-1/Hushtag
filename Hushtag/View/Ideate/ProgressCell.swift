import UIKit

class ProgressCell: UIView {

    
    @IBOutlet weak var viewButton: UIButton!


    @IBOutlet weak var graphView: UIView!
    var scriptedIdea: ScriptedIdea?
    var onViewIdeaTapped: (() -> Void)?


        private let milestones: [String] = ["Script", "Title", "Description"]
        private let typeOrder: [String] = ["script", "title", "description"]

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
        override func awakeFromNib() {
            super.awakeFromNib()
            setupProgressBar()
        }
        private var milestoneDots: [UIView] = []
        private var milestoneCheckmarks: [UIImageView] = []
        private var milestoneLabels: [UILabel] = []
        private var progressWidthConstraint: NSLayoutConstraint?
        private var middleDotCenterXConstraints: [NSLayoutConstraint] = []
        private var lastWidth: CGFloat = 0

        override init(frame: CGRect) {
            super.init(frame: frame)
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }


    private func setupProgressBar() {

        graphView.addSubview(trackView)
        trackView.addSubview(progressView)

        // Track constraints (NO vertical alignment yet)
        NSLayoutConstraint.activate([
            trackView.leadingAnchor.constraint(equalTo: graphView.leadingAnchor, constant: horizontalInset + dotSize / 2),
            trackView.trailingAnchor.constraint(equalTo: graphView.trailingAnchor, constant: -(horizontalInset + dotSize / 2)),
            trackView.heightAnchor.constraint(equalToConstant: trackHeight),

            progressView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            progressView.topAnchor.constraint(equalTo: trackView.topAnchor),
            progressView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),
        ])

        progressWidthConstraint = progressView.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: 0.001)
        progressWidthConstraint?.isActive = true

        // CREATE DOTS FIRST
        for (index, milestone) in milestones.enumerated() {
            let dot = UIView()
            dot.layer.cornerRadius = dotSize / 2
            dot.layer.borderWidth = 2
            dot.layer.borderColor = UIColor.systemGray3.cgColor
            dot.backgroundColor = .clear
            dot.translatesAutoresizingMaskIntoConstraints = false
            graphView.addSubview(dot)
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
            graphView.addSubview(label)
            milestoneLabels.append(label)

            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: dotSize),
                dot.heightAnchor.constraint(equalToConstant: dotSize),


                checkmark.centerXAnchor.constraint(equalTo: dot.centerXAnchor),
                checkmark.centerYAnchor.constraint(equalTo: dot.centerYAnchor),

                label.topAnchor.constraint(equalTo: dot.bottomAnchor, constant: 6),
                label.centerXAnchor.constraint(equalTo: dot.centerXAnchor),
            ])

            switch index {
            case 0:
                dot.leadingAnchor.constraint(equalTo: graphView.leadingAnchor, constant: horizontalInset).isActive = true
            case milestones.count - 1:
                dot.trailingAnchor.constraint(equalTo: graphView.trailingAnchor, constant: -horizontalInset).isActive = true
            default:
                let centerX = dot.centerXAnchor.constraint(equalTo: graphView.leadingAnchor)
                centerX.isActive = true
                middleDotCenterXConstraints.append(centerX)
            }
        }

        // ✅ NOW ALIGN EVERYTHING TOGETHER (AFTER DOTS EXIST)
        guard let firstDot = milestoneDots.first else { return }

        trackView.centerYAnchor.constraint(equalTo: firstDot.centerYAnchor).isActive = true
        trackView.centerYAnchor.constraint(equalTo: graphView.topAnchor, constant: 15).isActive = true

        for dot in milestoneDots {
            dot.centerYAnchor.constraint(equalTo: trackView.centerYAnchor).isActive = true
        }
    }
        @IBAction func viewIdea(_ sender: Any) {
            onViewIdeaTapped?()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            let width = graphView.bounds.width
            guard width > 0, width != lastWidth else { return }
            lastWidth = width

            for (i, constraint) in middleDotCenterXConstraints.enumerated() {
                let milestoneIndex = i + 1
                let fraction = CGFloat(milestoneIndex) / CGFloat(milestones.count - 1)
                let trackWidth = width - (horizontalInset * 2) - dotSize
                constraint.constant = horizontalInset + (dotSize / 2) + trackWidth * fraction
            }
        }

    func configure(completedTypes: Set<String>) {
        if milestoneDots.isEmpty {
            setupProgressBar()
        }

        let reordered = typeOrder.filter { completedTypes.contains($0) }
                     + typeOrder.filter { !completedTypes.contains($0) }

        let completedCount = completedTypes.count
        let fraction: CGFloat = completedCount == 0 ? 0.001 :
            CGFloat(completedCount - 1) / CGFloat(milestones.count - 1)

        progressWidthConstraint?.isActive = false
        progressWidthConstraint = progressView.widthAnchor.constraint(
            equalTo: trackView.widthAnchor,
            multiplier: max(fraction, 0.001)
        )
        progressWidthConstraint?.isActive = true

            for (index, dot) in milestoneDots.enumerated() {
                guard index < reordered.count else { continue }
                let type = reordered[index]
                let isActive = completedTypes.contains(type)

                milestoneLabels[index].text = type.capitalized

                UIView.animate(withDuration: 0.25) {
                    dot.layer.borderColor = isActive ? UIColor.accent.cgColor : UIColor.systemGray3.cgColor
                    dot.backgroundColor = isActive ? UIColor.accent : .clear
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
