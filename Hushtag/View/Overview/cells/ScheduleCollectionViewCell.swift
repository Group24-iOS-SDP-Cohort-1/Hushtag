import UIKit

class ScheduleCollectionViewCell: UICollectionViewCell {
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var completedButton: UIButton!
    weak var delegate: ScheduleCollectionViewCellDelegate?
    var indexPath: IndexPath?

    private var item: ScheduleItem?

    override func awakeFromNib() {
        super.awakeFromNib()
        applyLiquidGlassEffect()
    }

    func configure(with item: ScheduleItem) {
        self.item = item
        dayLabel.text = item.effectiveDeadline.dayOnly()
        switch item {
        case let .deal(deal, deliverable):
            if let deliverable = deliverable {
                // It's a sub-deliverable
                titleLabel.text = deliverable.name
                timeLabel.text = deliverable.deadline.timeOnly()
                // set completed status for deliverable
                updateCompletedButton(isCompleted: deliverable.isCompleted)
            } else {
                // It's the MAIN Deal
                titleLabel.text = "Deal: \(deal.name)"
                timeLabel.text = deal.deadline.timeOnly()
                // set completed status based on deal.isCompleted
                updateCompletedButton(isCompleted: deal.isCompleted)
            }
        }
    }

    private func updateCompletedButton(isCompleted: Bool) {
        let imageName = isCompleted ? "largecircle.fill.circle" : "circle"
        completedButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @IBAction func buttonTapped(_: UIButton) {
        guard let item = item,
              let indexPath = indexPath
        else {
            return
        }

        delegate?.didTapCompleted(item: item, indexPath: indexPath)
    }
}

protocol ScheduleCollectionViewCellDelegate: AnyObject {
    func didTapCompleted(item: ScheduleItem, indexPath: IndexPath)
}
