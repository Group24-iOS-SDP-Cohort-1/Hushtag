
import UIKit

class DetailsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mainName: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    @IBOutlet weak var remindersLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var deliverableLabel: UILabel!
    @IBOutlet weak var subNameLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    
    @IBOutlet weak var moreAction: UIButton!
    private let postsController = PostsController()
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
        case .post(let post, _):
            
            mainName.text = post.name
            if !post.platform.isEmpty {
                platformLabel.text = "Platform: " + post.platform.map(\.rawValue).joined(separator: ", ")
                platformLabel.isHidden = false
            }
            if let reminders = post.reminder, !reminders.isEmpty {
                remindersLabel.text = reminders
                    .sorted()
                    .map { $0.timeOnly() }
                    .joined(separator: ", ")
                
                remindersLabel.isHidden = false
            } else {
                remindersLabel.isHidden = true
            }
            
            
        case .deal(let deal, _):
            
            mainName.text = deal.name
            
            platformLabel.text = deal.platform.map(\.rawValue).joined(separator: ", ")
            platformLabel.isHidden = false
        }
    }
    
    func DealDetails(with deal: Deal) {
        
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
    
    func configureMultiple(with task: Tasks) {
        subNameLabel.text = task.name
        deadlineLabel.text = task.deadline.dateAndMonth()
        updateCompletionState(isCompleted: task.isCompleted)
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
    
    @IBAction func didTapStatusButton(_ sender: UIButton) {
        guard let indexPath = indexPath else { return }
            onToggleCompletion?(indexPath)
    }
    
    private func editTapped() {
        onEditTapped?()
    }
    
    private func deleteTapped() {
        //print("🗑 deleteTapped called")
        onDeleteTapped?()
    }
}
