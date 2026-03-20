import UIKit

class HeaderView: UICollectionReusableView {

    @IBOutlet weak var headerView: UILabel!
    
    var didTapChevron: (() -> Void)?
    
    // Programmatic chevron if XIB is not updated or for easier management
    private let chevronButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let image = UIImage(systemName: "chevron.right", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .secondaryLabel
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupChevron()
    }
    
    private func setupChevron() {
        addSubview(chevronButton)
        NSLayoutConstraint.activate([
            chevronButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chevronButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronButton.widthAnchor.constraint(equalToConstant: 24),
            chevronButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        chevronButton.addTarget(self, action: #selector(chevronTapped), for: .touchUpInside)
    }
    
    @objc private func chevronTapped() {
        didTapChevron?()
    }
    
    func configureHeader(text:String){
        headerView.text = text
    }
    
    func showChevron(_ show: Bool) {
        chevronButton.isHidden = !show
    }
}
