//
//  DeliverableCellAddDeal.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit
protocol DeliverableCellAddDealDelegate: AnyObject {
    func deliverableCellDidTapAdd(_ cell: DeliverableCellAddDeal)
}

class DeliverableCellAddDeal: UITableViewCell {
    weak var delegate: DeliverableCellAddDealDelegate?
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var addButton: UIButton!
    
    private var deliverableTextFields: [UITextField] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none

                // Card look
                cardView.layer.cornerRadius = 16
                cardView.layer.masksToBounds = true
                cardView.layer.borderWidth = 0.5
                cardView.layer.borderColor = UIColor.systemGray4.cgColor

                // Button style
                addButton.setTitle("+ Deliverables", for: .normal)
                addButton.setTitleColor(.systemPurple, for: .normal)
    }
    
    func configure(initialPlaceholders: [String]) {
            // If we already have fields, don't recreate them (prevents losing text)
            guard deliverableTextFields.isEmpty else { return }

            for placeholder in initialPlaceholders {
                addDeliverableField(placeholder: placeholder)
            }
        }

        /// Public: called from VC when + is tapped
        func addDeliverableField(placeholder: String) {
            let tf = UITextField()
            tf.placeholder = placeholder
            tf.borderStyle = .none
            tf.font = UIFont.systemFont(ofSize: 16)
            tf.heightAnchor.constraint(equalToConstant: 44).isActive = true

            // Insert above the button
            let index = max(stackView.arrangedSubviews.count - 1, 0)
            stackView.insertArrangedSubview(tf, at: index)

            deliverableTextFields.append(tf)
        }

        /// Optional: read all texts
        var deliverablesText: [String] {
            deliverableTextFields.map { $0.text ?? "" }
        }
    
    
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        delegate?.deliverableCellDidTapAdd(self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
