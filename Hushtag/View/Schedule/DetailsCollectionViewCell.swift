//
//  DetailsCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 20/01/26.
//

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
    private var currentTask: Tasks?
    var onToggleCompletion: ((Bool) -> Void)?
    private var isCompleted: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configureCommon(with item: ScheduleItem) {
        
        // Reset / hide everything first
        [
            platformLabel,
            remindersLabel
        ].forEach {
            $0?.text = nil
            $0?.isHidden = true
        }
        
        switch item {
        case .post(let post, let task):
            
            mainName.text = post.name
            if !post.platform.isEmpty {
                platformLabel.text = "Platform: " + post.platform.map(\.rawValue).joined(separator: ", ")
                platformLabel.isHidden = false
            }
            if !post.reminder.isEmpty {
                remindersLabel.text = post.reminder.joined(separator: ", ")
                remindersLabel.isHidden = false
            }
           
        case .deal(let deal, let deliverable):
            
            mainName.text = deal.name

            platformLabel.text = "Platform: " + deal.platform.joined(separator: ", ")
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
        deadlineLabel.text = task.deadline.dayOnly()   // <-- uses Date extension
        isCompleted = task.isCompleted
        updateCompletionState(isCompleted: isCompleted)
    }

    func configureMultiple(with deliverable: Deliverable) {
        subNameLabel.text = deliverable.name
        deadlineLabel.text = deliverable.deadline.dayOnly()
        isCompleted = deliverable.isCompleted
        updateCompletionState(isCompleted: isCompleted)
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
        isCompleted.toggle()
        updateCompletionState(isCompleted: isCompleted)
        onToggleCompletion?(isCompleted)
    }
}
