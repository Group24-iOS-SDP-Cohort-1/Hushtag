//
//  FieldTableViewCell.swift
//  Hushtag
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class FieldTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var onTextChanged: ((String) -> Void)?
    var onDateChanged: ((Date) -> Void)?
    
    let values = [
        ["Name", "Deliverables", "Platform", "Phone", "Email"],
        ["Name", "Posting Time", "Platform", "Description", "Reminder(s)"]
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        datePicker.isHidden = true
        textField.delegate = self
        // wire date picker change
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    func configure(index: Int, category: String, initialText: String? = nil, initialDate: Date? = nil) {
            if category == "Deals" {
                labelName.text = values[0][index]
                datePicker.isHidden = true
                textField.isHidden = false
            } else {
                labelName.text = values[1][index]
                if index == 1 {
                    datePicker.isHidden = false
                    textField.isHidden = true
                } else {
                    datePicker.isHidden = true
                    textField.isHidden = false
                }
            }

            textField.text = initialText
            if let d = initialDate {
                datePicker.date = d
            }
        }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
            onTextChanged?(textField.text ?? "")
        }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            onTextChanged?(textField.text ?? "")
            return true
        }

        @objc func dateChanged(_ sender: UIDatePicker) {
            onDateChanged?(sender.date)
        }


}
