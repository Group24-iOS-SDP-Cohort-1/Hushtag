import UIKit

class DealsCollectionViewCell: UICollectionViewCell {
    @IBOutlet var cardView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var deadlineValueLabel: UILabel!
    @IBOutlet var deliverablesValueLabel: UILabel!
    @IBOutlet var paymentValueLabel: UILabel!
    @IBOutlet var nextDeliverableLabel: UILabel!
    @IBOutlet var deadlineIconImageView: UIImageView!
    @IBOutlet var bottomStackView: UIStackView!
    @IBOutlet var navigationButton: UIButton!
    @IBOutlet var captionLabel: UILabel!

    var onTap: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardAppearance()
        navigationButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    @objc func handleTap() {
        onTap?()
    }

    private func setupCardAppearance() {
        cardView.layer.cornerRadius = 15
        cardView.layer.cornerCurve = .continuous
        cardView.applyLiquidGlassEffect()
        cardView.layer.masksToBounds = false
    }

    func configure(with deal: Deal, isCompleted: Bool) {
        titleLabel.text = deal.name
        paymentValueLabel.text = "\(deal.payment)"

        let total = deal.deliverables.count
        let completed = deal.deliverables.filter { $0.isCompleted }.count

        if isCompleted {
            deadlineIconImageView.image = UIImage(systemName: "play.circle")
            bottomStackView.isHidden = true
            captionLabel.isHidden = true
            nextDeliverableLabel.isHidden = true

            deliverablesValueLabel.textAlignment = .center
            deliverablesValueLabel.text = "\(completed) / \(total)"
            deadlineValueLabel.text = deal.platform.first?.rawValue.capitalized ?? "Platform"
            deadlineValueLabel.font = paymentValueLabel.font
            deadlineValueLabel.textColor = paymentValueLabel.textColor
        } else {
            deadlineIconImageView.image = UIImage(systemName: "calendar")
            bottomStackView.isHidden = false
            captionLabel.isHidden = false
            nextDeliverableLabel.isHidden = false

            deliverablesValueLabel.text = "\(completed) / \(total)"
            captionLabel.text = completed == 0 && !deal.deliverables.isEmpty ? "Get started with" : "Next Deliverable"
            deadlineValueLabel.text = deal.deadline.deadlineFormatted()
            updateNextDeadline(deal)
        }
    }

    private func updateNextDeadline(_ deal: Deal) {
        if deal.deliverables.isEmpty {
            nextDeliverableLabel.text = "-"
            return
        }

        let pending = deal.deliverables.filter { !$0.isCompleted }

        guard let deliverable = pending.min(by: { $0.deadline < $1.deadline }) else {
            nextDeliverableLabel.text = "-"
            return
        }

        nextDeliverableLabel.text = deliverable.name
    }
}
