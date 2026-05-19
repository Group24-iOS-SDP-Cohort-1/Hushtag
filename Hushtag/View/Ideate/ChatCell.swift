import UIKit

class ChatCell: UITableViewCell {
    @IBOutlet var chatView: UIView!
    @IBOutlet var chatLabel: UILabel!
    @IBOutlet var leftSpacer: UIView!
    @IBOutlet var rightSpacer: UIView!
    @IBOutlet var starImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        chatView.layer.cornerRadius = 16
    }

    func configure(with message: Message) {
        chatLabel.numberOfLines = 0

        if message.role == "user" {
            chatLabel.text = message.content
        } else {
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
}
