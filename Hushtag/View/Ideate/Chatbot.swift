//
//  Chatbot.swift
//  Hushtag
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

class Chatbot: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, LikedCellDelegate {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var textView: UIView!

    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var textFieldView: UITextView!

    @IBOutlet weak var textStack: UIStackView!

    @IBOutlet weak var enterbutton: UIButton!

    @IBOutlet weak var generateStack: UIStackView!

    var messages: [Message] = []
    var autoSendMessage: String?

    let botDatabase: [String: String] = [
            "hi": "hello",
            "hello": "Hi! How can I help you today?",
            "script": "Beauty isn’t about hiding who you are.It’s about enhancing what already exists.Every texture, every shade, every detail tells a story.No filters. No pressure. Just self-care and confidence.Because when you feel good, you glow differently. 💄✨",
            "idea": "You can make a beauty product review",
            "title": "Real Beauty, Real Confidence",
            "default": "Beauty isn’t about perfection — it’s about embracing what makes you you.No filters. No pressure. Just self-care, confidence, and a glow that comes from within."
        ]

    var markedMessages: [String: [Message]] = [
        "script": [],
        "title": [],
        "description": []
    ]

    let maxLines: CGFloat = 10
    let minLines: CGFloat = 3
    let lineHeight: CGFloat = 100
    override func viewDidLoad() {
        super.viewDidLoad()
        // Table setup
                tableView.delegate = self
                tableView.dataSource = self
                tableView.separatorStyle = .none
                tableView.reloadData()

                // Container view
                textView.clipsToBounds = false
                textView.layer.backgroundColor = UIColor.clear.cgColor

                // Send button
                enterbutton.widthAnchor.constraint(equalToConstant: 60).isActive = true
                enterbutton.heightAnchor.constraint(equalToConstant: 60).isActive = true
                enterbutton.layer.cornerRadius = 30
                enterbutton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)

                // UITextView setup
                textFieldView.delegate = self
                textFieldView.isScrollEnabled = false
                textFieldView.layer.borderWidth = 0.1
                textFieldView.layer.borderColor = UIColor.gray.cgColor
                textFieldView.layer.cornerRadius = 16
                textFieldView.clipsToBounds = true
                textFieldView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

                // Shadow
                textFieldView.layer.shadowColor = UIColor.gray.cgColor
                textFieldView.layer.shadowOpacity = 0.2
                textFieldView.layer.shadowOffset = CGSize(width: 0, height: 2)
                textFieldView.layer.shadowRadius = 4
                textFieldView.layer.masksToBounds = false

                // Stack alignment
                textStack.alignment = .bottom
                textStack.distribution = .fill

                //to load buttons of generate ideas,title,description
                //showScriptSuggestions()
                generateStack.isHidden = true

                if let text = autoSendMessage {
                    sendAutoMessage(text)
                    autoSendMessage = nil // prevent duplication
                }
}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return messages.count
        }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
            cell.configure(with: messages[indexPath.row])

            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            longPress.minimumPressDuration = 0.5
            cell.contentView.addGestureRecognizer(longPress)
            cell.contentView.tag = indexPath.row
            return cell

    }

    func textViewDidChange(_ textView: UITextView) {

        guard textView.font != nil else { return }

        let lineHeight = textView.font?.lineHeight ?? 0
        let inset = textView.textContainerInset.top + textView.textContainerInset.bottom

        let maxHeight = (lineHeight * 10) + inset
        let minHeight = (lineHeight * 3) + inset

        let size = CGSize(width: textView.frame.width, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)
            let contentHeight = estimatedSize.height

        if contentHeight >= maxHeight {
            textViewHeightConstraint.constant = maxHeight
            textView.isScrollEnabled = true
        }
        else if contentHeight < maxHeight && contentHeight > minHeight{
            textViewHeightConstraint.constant = contentHeight
            textView.isScrollEnabled = false
        }
        else if contentHeight <= minHeight {
            textViewHeightConstraint.constant = minHeight
            textView.isScrollEnabled = false
        }

        UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
    }

    func sendMessage(_ text: String) {
        messages.append(Message(text: text, isUser: true))
        tableView.reloadData()

        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)

        textFieldView.text = ""
        textViewDidChange(textFieldView)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.generateBotReply(for: text)
                }
    }

    func generateBotReply(for userText: String) {
        let input = userText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        let output: String
        if let response = botDatabase[input] {
            output = response
        } else if let responseDefault = botDatabase["default"] {
            output = responseDefault
        } else {
            output = "Sorry"
        }

        messages.append(Message(text: output, isUser: false))
        tableView.reloadData()

        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    
    @IBAction func sendButton(_ sender: Any) {
        let text = textFieldView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                sendMessage(text)
            }
    }

    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {

        //to trigger action once the press begins
        guard gesture.state == .began else { return }
        //to get the view that we long pressed
        guard let cellView = gesture.view else { return }
        //to store the row the cell belongs to
        let row = cellView.tag
        //message object corresponsding to that row
        var message = messages[row]

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

           // Helper to add mark/unmark option
           func addMarkAction(type: String) {
               let isMarked = message.markType == type
               let title = isMarked ? "Unmark \(type.capitalized)" : "Mark as \(type.capitalized)"

               alert.addAction(UIAlertAction(title: title, style: .default) { _ in
                   if isMarked {
                       message.markType = nil
                       self.markedMessages[type]?.removeAll(where: { $0.text == message.text })
                       self.showScriptSuggestions()
                   } else {
                       self.generateStack.isHidden = false
                       message.markType = type
                       self.markedMessages[type]?.append(message)
                       
                       switch type {
                               case "script":
                                   self.showScriptSuggestions(except: ["script"])
                               case "title":
                                   self.showScriptSuggestions(except: ["script", "title"])
                               case "description":
                                   self.showScriptSuggestions(except: ["script", "title", "description"])
                               default:
                                   self.showScriptSuggestions()
                               }
                   }
                   self.messages[row] = message
                   self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
               })
           }

           ["script", "title", "description"].forEach { addMarkAction(type: $0) }

           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
           self.present(alert, animated: true)

    }


    func showScriptSuggestions(except excludedTypes: [String] = []) {
        // Remove previous buttons
        generateStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // All possible suggestions
        var items = ["Generate Title", "Generate Description", "Generate Thumbnail"]

        // Remove excluded items
        if excludedTypes.contains("script") { items.removeAll { $0 == "Generate Scripts" } }
        if excludedTypes.contains("title") { items.removeAll { $0 == "Generate Title" } }
        if excludedTypes.contains("description") { items.removeAll { $0 == "Generate Description" } }

        for item in items {
            if let view = Bundle.main.loadNibNamed("SuggestionCell", owner: self, options: nil)?.first as? SuggestionCell {
                view.generateButton.setTitle(item, for: .normal)
                view.generateButton.addTarget(self, action: #selector(generateButtonTapped(_:)), for: .touchUpInside)
                generateStack.addArrangedSubview(view)
            }
        }

        generateStack.layoutIfNeeded()
    }

    @objc func generateButtonTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        //to Send user message
        sendMessage(title)
        generateStack.isHidden = true
  }

    func didTapDraftScript(for idea: Idea) {

        //to Send the message immediately when user typed "script"
        sendAutoMessage("script")

        //to Mark it as script
        if let lastIndex = messages.indices.last {
            messages[lastIndex].markType = "script"
        }

        // Show buttons (title, description, thumbnail)
        generateStack.isHidden = false
        showScriptSuggestions(except: ["script"])
    }

    func sendAutoMessage(_ text: String) {

        messages.append(Message(text: text, isUser: true))
        tableView.reloadData()
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.generateBotReply(for: text)
        }
    }

}





