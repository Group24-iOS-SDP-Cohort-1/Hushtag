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

        // Keep masksToBounds = false so shadow is visible
        cardView.layer.masksToBounds = false

        // Subtle shadow
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.15
        cardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cardView.layer.shadowRadius = 6

        // Chevron
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
    
    func configure(with deal: Deal) {
        titleLabel.text = deal.name

        // Payment
        paymentValueLabel.text = "Rs \(deal.payment)"

        // Deliverables count
        // Deliverables count based on isCompleted flag
        let total = deal.deliverable.count
        let completed = deal.deliverable.filter { $0.isCompleted }.count
        deliverablesValueLabel.text = "\(completed) / \(total) done"
        
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]

        let now = Date()

        if completed == 0 {
                captionLabel.text = "Get started with"
            } else {
                captionLabel.text = "Next deliverable"
            }
        
        let deliverablesWithDates: [(Deliverable, Date)] = deal.deliverable.compactMap { item in
            guard let dateString = item.deadline.date,
                  let date = isoFormatter.date(from: dateString)
            else { return nil }
            return (item, date)
        }

        
        let upcoming = deliverablesWithDates.filter { $0.1 >= now }
        let chosen = upcoming.min(by: { $0.1 < $1.1 })
            ?? deliverablesWithDates.min(by: { $0.1 < $1.1 })

        
        if let (deliverable, date) = chosen {
            nextDeliverableLabel.text = deliverable.name
            deadlineValueLabel.text = formatDeadline(ISO8601DateFormatter().string(from: date))
        } else {
            nextDeliverableLabel.text = "-"
            deadlineValueLabel.text = deal.platform.joined(separator: ", ")
        }
    }
}



