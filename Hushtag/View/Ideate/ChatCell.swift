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

    @IBOutlet weak var leftSpacer: UIView!

    @IBOutlet weak var rightSpacer: UIView!

    @IBOutlet weak var starImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        ChatView.layer.cornerRadius = 16


    }

    func configure(with message: Message) {
        ChatLabel.text = message.text
        ChatLabel.numberOfLines = 0

        if message.markType != nil {
            starImage.isHidden = false
               } else {
                   starImage.isHidden = true
               }

        if message.isUser {
            ChatView.backgroundColor = UIColor.accent
            ChatLabel.textColor = .white
            leftSpacer.isHidden = false
            rightSpacer.isHidden = true
                } else {
                    ChatView.backgroundColor = UIColor.systemGray5
                    ChatLabel.textColor = .black
                    leftSpacer.isHidden = true
                    rightSpacer.isHidden = false
                }
       }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
