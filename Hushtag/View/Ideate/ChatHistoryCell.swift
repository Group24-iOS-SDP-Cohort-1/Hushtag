//
//  ChatHistoryCell.swift
//  Hushtag
//
//  Created by SDC-USER on 19/02/26.
//

import UIKit

class ChatHistoryCell: UITableViewCell {

    let controller = ScriptedIdeasController()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(with conversation: Conversation) {

        titleLabel.text = "Loading..."
        timeLabel.text = conversation.created_at?.timeOnly()

        Task {
            do {
                // 1. Fetch messages for this conversation
                let msgs = try await controller.fetchMessages(for: conversation.id)

                guard !msgs.isEmpty else {
                    await MainActor.run {
                        self.titleLabel.text = "Empty Chat"
                    }
                    return
                }

                // 2. Generate AI title from messages
                let aiTitle = try await controller.generateConversationTitleWithApple(
                    messages: msgs
                )

                // 3. Update UI
                await MainActor.run {
                    self.titleLabel.text = aiTitle
                }

            } catch {
                await MainActor.run {
                    self.titleLabel.text = "Conversation"
                }
            }
        }
    }

}
