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

    @IBOutlet weak var deadlineTitleLabel: UILabel!
    @IBOutlet weak var deadlineIconImageView: UIImageView!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var navigationButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    let customPurple = UIColor(_colorLiteralRed: 139/255, green: 92/255, blue: 246/255, alpha: 1)
    
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
        // Rounded corners
        cardView.layer.cornerRadius = 15
        cardView.layer.cornerCurve = .continuous
        cardView.backgroundColor = .white
        cardView.layer.masksToBounds = false

        // Subtle shadow
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.15
        cardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cardView.layer.shadowRadius = 6

    }

    func formatDeadline(_ isoString: String) -> String {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime]

            guard let date = isoFormatter.date(from: isoString) else {
                return isoString   // fallback if parsing fails
            }

            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM dd"
            displayFormatter.locale = Locale.current

            return displayFormatter.string(from: date)
        }
    
    func configure(with deal: Deal, isCompleted: Bool) {
        titleLabel.text = deal.name
        paymentValueLabel.text = "Rs \(deal.payment)"

        let total = deal.deliverable.count
        let completed = deal.deliverable.filter { $0.isCompleted }.count

        if isCompleted {
            deadlineTitleLabel.text = "Platform"
            deadlineIconImageView.image = UIImage(systemName: "network")
            bottomStackView.isHidden = true
            captionLabel.isHidden    = true
            nextDeliverableLabel.isHidden = true
            deliverablesValueLabel.textAlignment = .center
            deliverablesValueLabel.text = "\(completed) / \(total)"
            deadlineValueLabel.text      = deal.platform.joined(separator: ", ")
            deadlineValueLabel.font      = paymentValueLabel.font
            deadlineValueLabel.textColor = paymentValueLabel.textColor

        } else {
            deadlineTitleLabel.text = "Deadline"
            deadlineIconImageView.image = UIImage(systemName: "calendar")
            // show bottom area
            bottomStackView.isHidden = false
            captionLabel.isHidden    = false
            nextDeliverableLabel.isHidden = false

            deliverablesValueLabel.text = "\(completed) / \(total) done"
            updateNextDeadline(deal)
            
            if completed == 0 {
                captionLabel.text = "Get started with"
            }else{
                captionLabel.text = "Next Deliverable"
            }
        }
    }

    private func updateNextDeadline(_ deal: Deal) {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]

        //pending deliverables
        let pending = deal.deliverable.filter { !$0.isCompleted }

        //no pending items -> show dashes
        guard !pending.isEmpty else {
            nextDeliverableLabel.text = "-"
            deadlineValueLabel.text = "-"
            return
        }

        var chosenDeliverable: Deliverable?
        var chosenDate: Date?

        let withDates: [(Deliverable, Date)] = pending.compactMap { item in
            if let dateString = item.deadline.date,
               let date = isoFormatter.date(from: dateString) {
                return (item, date)
            }
            return nil
        }

        if !withDates.isEmpty {
            chosenDate = withDates.map { $0.1 }.min()
            if let cd = chosenDate {
                chosenDeliverable = withDates.first { $0.1 == cd }?.0
            }
        }

        if chosenDeliverable == nil {
            chosenDeliverable = pending.first
            chosenDate = nil
            if let dateString = chosenDeliverable?.deadline.date,
               let d = isoFormatter.date(from: dateString) {
                chosenDate = d
            }
        }

        //update UI
        if let deliverable = chosenDeliverable {
            nextDeliverableLabel.text = deliverable.name
            if let date = chosenDate {
                deadlineValueLabel.text = formatDeadline(isoFormatter.string(from: date))
            } else {
                deadlineValueLabel.text = "-"
            }
        } else {
            nextDeliverableLabel.text = "-"
            deadlineValueLabel.text = "-"
        }
    }
}



