import UIKit

class DetailsCollectionViewCell: UICollectionViewCell {
    @IBOutlet var mainName: UILabel!
    @IBOutlet var platformLabel: UILabel!
    @IBOutlet var remindersLabel: UILabel!
    @IBOutlet var paymentLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var deliverableLabel: UILabel!
    @IBOutlet var subNameLabel: UILabel!
    @IBOutlet var deadlineLabel: UILabel!
    @IBOutlet var statusButton: UIButton!
    @IBOutlet var moreAction: UIButton!
    var onToggleCompletion: ((IndexPath) -> Void)?
    var onDeleteTapped: (() -> Void)?
    var onEditTapped: (() -> Void)?
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureMoreMenuIfNeeded()
    }

    private func configureMoreMenuIfNeeded() {
        guard let moreAction else { return }

        let editAction = UIAction(
            title: "Edit",
            image: UIImage(systemName: "pencil")
        ) { [weak self] _ in
            self?.editTapped()
        }

        let deleteAction = UIAction(
            title: "Delete",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.deleteTapped()
        }

        moreAction.menu = UIMenu(children: [editAction, deleteAction])
        moreAction.showsMenuAsPrimaryAction = true
    }

    func configureCommon(with item: ScheduleItem) {
        [
            platformLabel,
            remindersLabel
        ].forEach {
            $0?.text = nil
            $0?.isHidden = true
        }

        switch item {
        case let .deal(deal, _):
            mainName.text = deal.name

            platformLabel.text = deal.platform.map(\.rawValue).joined(separator: ", ")
            platformLabel.isHidden = false

            if statusButton != nil {
                updateCompletionState(isCompleted: deal.isCompleted)
            }

        case let .youtubeUpload(upload):
            mainName.text = upload.title
            platformLabel.text = "YouTube (\(upload.privacyStatus?.capitalized ?? "Public"))"
            platformLabel.isHidden = false

            if let pubAt = upload.publishAt {
                remindersLabel.text = pubAt.timeOnly()
                remindersLabel.isHidden = false
            }

            if statusButton != nil {
                updateCompletionState(isCompleted: upload.uploadStatus == "completed")
            }
        }
    }

    func dealDetails(with deal: Deal) {
        let completedCount = deal.deliverables.filter { $0.isCompleted }.count
        let totalCount = deal.deliverables.count

        paymentLabel.text = "\(deal.payment)"
        paymentLabel.isHidden = false

        phoneLabel.text = "\(deal.mobileNumber)"
        phoneLabel.isHidden = false

        emailLabel.text = deal.email
        emailLabel.isHidden = false

        deliverableLabel.text = "\(completedCount) / \(totalCount)"
        deliverableLabel.isHidden = false
    }

    func configureMultiple(with deliverable: Deliverable) {
        subNameLabel.text = deliverable.name
        deadlineLabel.text = deliverable.deadline.dateAndMonth()
        updateCompletionState(isCompleted: deliverable.isCompleted)
    }

    private func updateCompletionState(isCompleted: Bool) {
        let symbolName = isCompleted ? "largecircle.fill.circle" : "circle"

        let image = UIImage(
            systemName: symbolName,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        )

        statusButton.setImage(image, for: .normal)
    }

    @IBAction func didTapStatusButton(_: UIButton) {
        guard let indexPath = indexPath else { return }
        onToggleCompletion?(indexPath)
    }

    private func editTapped() {
        onEditTapped?()
    }

    private func deleteTapped() {
        // print("🗑 deleteTapped called")
        onDeleteTapped?()
    }
}
