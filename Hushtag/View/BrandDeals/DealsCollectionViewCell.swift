//
//  DealsCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit

class DealsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deadlineValueLabel: UILabel!
    @IBOutlet weak var deliverablesValueLabel: UILabel!
    @IBOutlet weak var paymentValueLabel: UILabel!
    @IBOutlet weak var nextDeliverableLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardAppearance()
        // enable multiline where needed
                titleLabel.numberOfLines = 1
                nextDeliverableLabel.numberOfLines = 2
                deadlineValueLabel.numberOfLines = 2
                deliverablesValueLabel.numberOfLines = 1
                paymentValueLabel.numberOfLines = 1

    }

    private func setupCardAppearance() {
        // Rounded corners
        cardView.layer.cornerRadius = 15
        cardView.layer.cornerCurve = .continuous
        cardView.backgroundColor = .white

        // Keep masksToBounds = false so shadow is visible
        cardView.layer.masksToBounds = false

        // Subtle shadow
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.15
        cardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cardView.layer.shadowRadius = 6

        // Chevron
        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = .systemGray
    }


    func configure(with deal: Deal) {
        // Title
        titleLabel.text = deal.name

        // Payment
        paymentValueLabel.text = "Rs \(deal.payment)"

        // Deliverables count
        let count = deal.deliverable.count
        deliverablesValueLabel.text = "\(count) deliverable" + (count == 1 ? "" : "s")

        // Next deliverable name (or placeholder)
        if let first = deal.deliverable.first {
            nextDeliverableLabel.text = first.name
            // Show the raw date string if present; otherwise show platform(s) as fallback
            if let rawDate = first.deadline.date, !rawDate.isEmpty {
                deadlineValueLabel.text = rawDate
            } else {
                deadlineValueLabel.text = deal.platform.joined(separator: ", ")
            }
        } else {
            nextDeliverableLabel.text = "-"
            deadlineValueLabel.text = deal.platform.joined(separator: ", ")
        }
    }
}
