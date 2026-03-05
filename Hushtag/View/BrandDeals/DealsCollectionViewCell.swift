//
//  DealsCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class DealsCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deadlineValueLabel: UILabel!
    @IBOutlet weak var deliverablesValueLabel: UILabel!
    @IBOutlet weak var paymentValueLabel: UILabel!
    @IBOutlet weak var nextDeliverableLabel: UILabel!
    @IBOutlet weak var deadlineIconImageView: UIImageView!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var navigationButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    
    var onTap : (() -> Void)?
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
