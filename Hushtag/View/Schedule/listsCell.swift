//
//  listsCell.swift
//  Hushtag
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class listsCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(lists: (String, Int)) {
        nameLabel.text = lists.0
        valueLabel.text = "\(lists.1)"
    }
}
