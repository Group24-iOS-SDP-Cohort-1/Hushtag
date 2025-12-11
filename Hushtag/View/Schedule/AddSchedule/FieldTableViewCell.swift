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
    let values = [
        ["Name", "Start Date", "End Date", "Description", "Reminder(s)"],
        ["Name", "Deliverables", "Platform", "Phone", "Email"],
        ["Name", "Posting Time", "Platform", "Description", "Reminder(s)"]
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        datePicker.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(index: Int, category: String) {
        if category == "Tasks" {
            labelName.text = values[0][index]
            if index == 1 || index == 2 {
                datePicker.isHidden = false
                textField.isHidden = true
            }
        } else if category == "Deals" {
            labelName.text = values[1][index]
            
        } else {
            labelName.text = values[2][index]
            if index == 1 {
                datePicker.isHidden = false
                textField.isHidden = true
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


}
