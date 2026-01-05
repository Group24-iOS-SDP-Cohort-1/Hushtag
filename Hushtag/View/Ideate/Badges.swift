//
//  Badges.swift
//  Hushtag
//
//  Created by SDC-USER on 18/12/25.
//

import UIKit

class Badges: UIView {

    @IBOutlet weak var badgeLabel: UILabel!
    
    private var badgeCornerRadius: CGFloat = 12

    static func loadFromNib() -> Badges {
           let nib = UINib(nibName: "Badges", bundle: nil)
           return nib.instantiate(withOwner: nil, options: nil).first as! Badges
       }
       override func awakeFromNib() {
           super.awakeFromNib()
           setupUI()
       }

       override func layoutSubviews() {
           super.layoutSubviews()
           layer.cornerRadius = badgeCornerRadius
       }

       private func setupUI() {
           clipsToBounds = true

           badgeLabel.font = .systemFont(ofSize: 12, weight: .semibold)
           badgeLabel.textAlignment = .center
           badgeLabel.textColor = .white
       }

    func configure(text: String) {
        badgeLabel.text = text.uppercased()
        print("Badge text:", text)

        badgeCornerRadius = 10
        badgeLabel.textColor = .white

        layer.borderWidth = 0.5
        layer.borderColor = UIColor.white.cgColor
        backgroundColor = UIColor.white.withAlphaComponent(0.15)

        // Allow badge to adjust based on its content size
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.setContentHuggingPriority(.required, for: .horizontal)
        badgeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

}
