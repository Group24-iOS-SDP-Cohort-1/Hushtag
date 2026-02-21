//
//  ChatCell.swift
//  Hushtag
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

class ChatCell: UITableViewCell {
    
    
    @IBOutlet weak var chatView: UIView!
    
    @IBOutlet weak var chatLabel: UILabel!
    
    @IBOutlet weak var leftSpacer: UIView!
    
    @IBOutlet weak var rightSpacer: UIView!
    
    @IBOutlet weak var starImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chatView.layer.cornerRadius = 16
    }
    
    func configure(with message: Message) {
        
        chatLabel.numberOfLines = 0
        
        if message.role == "user" {
            chatLabel.text = message.content
        }else{
            chatLabel.attributedText = message.content.toStyledScript()
        }
        
        
        if message.mark != nil {
            starImage.isHidden = false
        } else {
            starImage.isHidden = true
        }
        
        if message.role == "user" {
            chatView.backgroundColor = UIColor.accent
            chatLabel.textColor = .white
            leftSpacer.isHidden = false
            rightSpacer.isHidden = true
        } else {
            chatView.backgroundColor = UIColor.systemGray4
            chatLabel.textColor = .white
            leftSpacer.isHidden = true
            rightSpacer.isHidden = false
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
