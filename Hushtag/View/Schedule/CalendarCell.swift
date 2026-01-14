//
//  CalendarCell.swift
//  Hushtag
//
//  Created by SDC-USER on 13/01/26.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
            super.awakeFromNib()
        contentView.layer.cornerRadius = 12
    }

    func configure(day: String, date: String, isSelected: Bool) {
        dayLabel.text = day
        dateLabel.text = date
        if isSelected {
            contentView.backgroundColor = .accent
            dayLabel.textColor = .white
            dateLabel.textColor = .white
        } else {
            contentView.backgroundColor = .clear
            dayLabel.textColor = .lightGray
            dateLabel.textColor = .white
        }
    }
}
