//
//  ChatCell.swift
//  Hushtag
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

class ChatCell: UITableViewCell {


    @IBOutlet weak var ChatView: UIView!

    @IBOutlet weak var ChatLabel: UILabel!
    
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!

    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ChatView.layer.cornerRadius = 16

    }

    func configure(with message: Message) {
           ChatLabel.text = message.text
        ChatLabel.numberOfLines = 0 
        if message.isUser {

            ChatView.backgroundColor = UIColor.accent
            ChatLabel.textColor = .white
//           rightConstraint.isActive = true
//           leftConstraint.isActive = false

                } else {
                    
                    ChatView.backgroundColor = UIColor.systemGray5
                    ChatLabel.textColor = .black
//                 leftConstraint.isActive = true
//                   rightConstraint.isActive = false
                }
       }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }

}
