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
    let maxLines: CGFloat = 10
    let minLines: CGFloat = 3
    let lineHeight: CGFloat = 100
    override func viewDidLoad() {
        super.viewDidLoad()
        // Table setup
                tableView.delegate = self
                tableView.dataSource = self
                tableView.separatorStyle = .none

                messages.append(Message(text: "Hello! I'm your AI assistant.", isUser: false))
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
}





