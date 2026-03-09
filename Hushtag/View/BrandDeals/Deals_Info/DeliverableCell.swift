import UIKit

final class DeliverableCell: UICollectionViewCell {
    
    static let reuseId = "DeliverableCell"
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var status: UIButton!
    
    var onToggleStatus: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        separatorView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        status.addTarget(self, action: #selector(toggleStatus), for: .touchUpInside)
        
    }
    
    func configure(with deliverable: Deliverable, isLast: Bool) {
        
        titleLabel.text = deliverable.name
        
        let day = deliverable.deadline.dayOnly()
        let date = deliverable.deadline.dateAndMonth()
        subtitleLabel.text = "Due \(day), \(date)"
        
        updateStatus(isCompleted: deliverable.isCompleted)
        separatorView.isHidden = isLast
    }
    
    @objc private func toggleStatus() {
        onToggleStatus?()
    }
    
    func updateStatus(isCompleted: Bool) {
        let imageName = isCompleted ? "circle.inset.filled" : "circle"
        status.setImage(UIImage(systemName: imageName), for: .normal)
        status.tintColor = .accent
    }
    
    
}
