import UIKit

class ChatHistoryCell: UITableViewCell {
    let controller = ScriptedIdeasController()
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    func configure(with conversation: Conversation) {
        titleLabel.text = conversation.title
        timeLabel.text = conversation.createdAt?.timeOnly()
    }
}
