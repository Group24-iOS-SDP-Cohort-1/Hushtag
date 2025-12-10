//
//  CompletedDealsCollectionViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

let customPurple = UIColor(_colorLiteralRed: 139/255, green: 92/255, blue: 246/255, alpha: 1)

class CompletedDealsCollectionViewCell: UICollectionViewCell {
    var onTap : (() -> Void)?
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleNameLabel: UILabel!
    
    @IBOutlet weak var platformNameLabel: UILabel!
    
    @IBOutlet weak var navigationButton: UIButton!
    @IBOutlet weak var paymentLabel: UILabel!
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
    func configure(with deal: Deal) {
            // Brand name
            titleNameLabel.text = deal.name

            // Payment
            paymentLabel.text = "Rs \(deal.payment)"

            // Platform (use first platform for the tag, like design)
            if let platform = deal.platform.first {
                let lower = platform.lowercased()
                platformNameLabel.text = platform.capitalized

                // Optional: color by platform (Instagram purple / YouTube red)
                switch lower {
                case "instagram":
                    platformNameLabel.textColor = customPurple
                case "youtube":
                    platformNameLabel.textColor = UIColor(red: 230/255, green: 33/255, blue: 23/255, alpha: 1)
                default:
                    platformNameLabel.textColor = .secondaryLabel
                }
            } else {
                platformNameLabel.text = ""
                platformNameLabel.textColor = .secondaryLabel
            }
        }
}
