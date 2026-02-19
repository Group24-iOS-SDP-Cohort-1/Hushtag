//
//  ChatHistoryCell.swift
//  Hushtag
//
//  Created by SDC-USER on 19/02/26.
//

import UIKit

class ChatHistoryCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(with message: ChatMessageDB) {
        titleLabel.text = message.content
        timeLabel.text = ""
    }

}
