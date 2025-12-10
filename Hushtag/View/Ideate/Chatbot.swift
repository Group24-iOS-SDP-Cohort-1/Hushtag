//
//  Chatbot.swift
//  Hushtag
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit



class Chatbot: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!


    @IBOutlet weak var textView: UIView!

    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var textFieldView: UITextView!

    @IBOutlet weak var textStack: UIStackView!

    @IBOutlet weak var Enterbutton: UIButton!

    var messages: [Message] = []

    let botDatabase: [String: String] = [
            "hi": "hello",
            "hello": "Hi! How can I help you today?",
            "script": "Sure! I can help you write a script. Tell me the topic!",
            "idea": "Looking for ideas? You can ask me for trending ideas anytime!",
            "title": "I can suggest optimized titles. What's your video about?",
            "default": "I'm not sure, but I’m learning! Try asking in another way"
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
                Enterbutton.widthAnchor.constraint(equalToConstant: 60).isActive = true
                Enterbutton.heightAnchor.constraint(equalToConstant: 60).isActive = true
                Enterbutton.layer.cornerRadius = 30
                Enterbutton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)

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


    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return messages.count
        }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
            cell.configure(with: messages[indexPath.row])

            //to remove existing duplicates
            //cell.contentView.gestureRecognizers?.forEach(cell.contentView.removeGestureRecognizer)

            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            longPress.minimumPressDuration = 0.5 // half a second
            cell.contentView.addGestureRecognizer(longPress)
            cell.contentView.tag = indexPath.row // store row in tag for refere

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
                   } else {
                       message.markType = type
                       self.markedMessages[type]?.append(message)
                   }
                   self.messages[row] = message
                   self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
               })
           }

           ["script", "title", "description"].forEach { addMarkAction(type: $0) }

           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
           self.present(alert, animated: true)

    }

}





