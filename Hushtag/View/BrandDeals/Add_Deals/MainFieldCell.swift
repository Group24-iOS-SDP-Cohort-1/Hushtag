//
//  MainFieldCell.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class MainFieldCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!

    let datePicker = UIDatePicker()
    var isDatePickerCell: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        contentView.layer.cornerRadius = 15
        contentView.clipsToBounds = true
        contentView.applyLiquidGlassEffect()


        textField.borderStyle = .none
        textField.backgroundColor = .clear

        // Date Picker Configuration
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }

    func configureForDatePicker() {
        if isDatePickerCell {
            textField.inputView = datePicker
        } else {
            textField.inputView = nil
        }
    }

    @objc func dateChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        textField.text = dateFormatter.string(from: datePicker.date)
    }
}
