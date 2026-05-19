import UIKit

class ChatHistoryCell: UITableViewCell {

    let controller = ScriptedIdeasController()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    func configure(with conversation: Conversation) {
        titleLabel.text = conversation.title
        timeLabel.text = conversation.created_at?.timeOnly()

    }

}
