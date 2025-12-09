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
    

    override func awakeFromNib() {
        super.awakeFromNib()
        ChatView.layer.cornerRadius = 16
    }

    func configure(with message: Message) {
           ChatLabel.text = message.text

           if message.isUser {
               ChatView.backgroundColor = .white
               ChatLabel.textColor = .black
           } else {
               ChatView.backgroundColor = UIColor(white: 0.93, alpha: 1) // ChatGPT-style grey
               ChatLabel.textColor = .black
           }
       }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }

}
