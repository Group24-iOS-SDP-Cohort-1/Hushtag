//
//  HeaderButton.swift
//  Hushtag
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class HeaderButton: UICollectionReusableView {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    var onDateChanged: ((Date) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.addTarget(
            self,
            action: #selector(dateDidChange(_:)),
            for: .valueChanged
        )
    }
    func configure() {
        headerLabel.text = "Today"
    }
    @objc private func dateDidChange(_ sender: UIDatePicker) {
        onDateChanged?(sender.date)
    }
}
