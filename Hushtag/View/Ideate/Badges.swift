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
           badgeLabel.textAlignment = .center
           badgeLabel.textColor = .white
       }

       func configure(
           text: String,
           color: UIColor = .white,
           cornerRadius: CGFloat = 12,
           borderWidth: CGFloat = 1,
           backgroundAlpha: CGFloat = 0.15
       ) {
           badgeLabel.text = "\(text)"
           badgeCornerRadius = cornerRadius
           badgeLabel.textColor = color
           layer.borderWidth = borderWidth
           layer.borderColor = color.cgColor
           backgroundColor = color.withAlphaComponent(backgroundAlpha)

           setNeedsLayout()
       }
   }
