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
    
    @IBOutlet weak var enterbutton: UIButton!
    
    @IBOutlet weak var generateStack: UIStackView!
    
    @IBOutlet weak var inputViewBottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var scriptedChats: UIBarButtonItem!
    var latestScript: String?
    var messages: [Message] = []
    var autoSendMessage: String?
    let controller = ScriptedIdeasController()
    var markedMessages: [String: [Message]] = [
        "script": [],
        "title": [],
        "description": [],
        "thumbnail": []
    ]
    
    let maxLines: CGFloat = 10
    let minLines: CGFloat = 3
    let lineHeight: CGFloat = 100
    let requiredMarkTypes = ["script", "title", "description", "thumbnail"]
    var didShowFinalReadyMessage = false
    var conversationID: UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.reloadData()
        textView.layer.backgroundColor = UIColor.clear.cgColor
        
        enterbutton.layer.cornerRadius = 30
        textFieldView.delegate = self
        textFieldView.isScrollEnabled = false
        textFieldView.layer.borderWidth = 0.2
        textFieldView.layer.borderColor = UIColor.white.cgColor
        textFieldView.layer.cornerRadius = 16
        textFieldView.layer.shadowColor = UIColor.gray.cgColor
        textFieldView.layer.shadowOpacity = 0.2
        textFieldView.layer.shadowOffset = CGSize(width: 0, height: 2)
        textFieldView.layer.shadowRadius = 4
        
        generateStack.isHidden = true
        
        if let text = autoSendMessage {
            sendAutoMessage(text)
            autoSendMessage = nil
        }
        
        // ✅ Only create new conversation if none exists
        if conversationID == nil {
            
            conversationID = UUID()
            print("🆕 New Conversation started:", conversationID!)
            
            Task {
                do {
                    _ = try await controller.addConversation(id: conversationID ?? UUID())
                    print("✅ Conversation created")
                } catch {
                    print("❌ Failed to create conversation:", error)
                }
            }
            
        } else {
            print("📌 Opening existing conversation:", conversationID!)
        }
        
        Task {
            do {
                let convo = try await controller.addConversation(id: conversationID ?? UUID())
                print("✅ Conversation inserted:", convo)
            } catch {
                print("❌ Failed to insert conversation:", error)
            }
        }
        
        Task {
            do {
                let history = try await controller.fetchMessages(for: conversationID ?? UUID())
                
                let mapped = history.map {
                    Message(role: $0.role.rawValue,
                            content: $0.content)
                }
                
                await MainActor.run {
                    self.messages = mapped
                    self.tableView.reloadData()
                    self.scrollToBottom()
                }
                
            } catch {
                print("❌ Failed loading conversation:", error)
            }
        }
        
        
        setupKeyboardObservers()
        setupTapToDismiss()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func isTypeAlreadyMarked(_ type: String) -> Bool {
        return !(markedMessages[type]?.isEmpty ?? true)
    }
    
    func isAllContentMarked() -> Bool {
        for type in requiredMarkTypes {
            if markedMessages[type]?.isEmpty ?? true {
                return false
            }
        }
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if messages.isEmpty {
            let welcomeMessage = "Welcome! I’m your scripting assistant. Lets write a script for you."
            messages.append(Message(role: "system", content: welcomeMessage))
            tableView.reloadData()
            scrollToBottom()
        }
    }
    
    
    @IBAction func scriptView(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ChatHistory", bundle: nil)
        guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController else {return}
        guard let destinationVC = navVC.topViewController as? ChatHistory else {return}
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    
    func setupTapToDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let bottomPadding = view.safeAreaInsets.bottom
            self.inputViewBottomConstraint.constant = keyboardSize.height - bottomPadding
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            
            scrollToBottom()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.inputViewBottomConstraint.constant = 8
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollToBottom() {
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
        
        let userText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userText.isEmpty else { return }
        
        // 1. Show user message
        messages.append(Message(role: "user", content: userText))
        tableView.reloadData()
        scrollToBottom()
        
        textFieldView.text = ""
        textViewDidChange(textFieldView)
        
        Task {
            do {
                _ = try await self.controller.addChatMessage(
                    id: conversationID ?? UUID(),
                    sender: .user,
                    content: userText
                )
                print("✅ User message saved")
            } catch {
                print("❌ Failed to save user message:", error)
            }
        }
        
        
        // 2. Show loading
        messages.append(Message(role: "bot", content: "Thinking..."))
        tableView.reloadData()
        scrollToBottom()
        
        // 3. Call Gemini
        //        GeminiManager.shared.generateContent(prompt: userText, conversationID: conversationID) { [weak self] replyText in
        //            guard let self = self else { return }
        //
        //            DispatchQueue.main.async {
        //
        //                // Remove Thinking...
        //                if !self.messages.isEmpty {
        //                    self.messages.removeLast()
        //                }
        //
        //                guard let replyText else {
        //                    self.messages.append(
        //                        Message(role: "bot", content: "Gemini Failed")
        //                    )
        //                    self.tableView.reloadData()
        //                    self.scrollToBottom()
        //                    return
        //                }
        //
        //                // Add bot reply
        //                self.messages.append(
        //                    Message(role: "bot", content: replyText)
        //                )
        //
        //                self.tableView.reloadData()
        //                self.scrollToBottom()
        //            }
        //
        //            // Save into Supabase (this can stay background)
        //            Task {
        //                try await self.controller.addChatMessage(
        //                    id: self.conversationID,
        //                    sender: .bot,
        //                    content: replyText ?? ""
        //                )
        //            }
        //        }
        
        // 3️⃣ Decide intent & route
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let intent = try await classifyIntent(userText)
                
                print(intent)
                
                switch intent {
                    
                case .generateScript:
                    // 🔥 Gemini writes script
                    print("routing to gemini")
                    GeminiManager.shared.generateContent(
                        prompt: userText,
                        conversationID: conversationID ?? UUID()
                    ) { reply in
                        self.latestScript = reply
                        self.handleBotReply(reply, source: "gemini")
                    }
                    
                case .generateTitle:
                    print("🍎 routing to apple (title)")
                    
                    let reply = try await generateTitleWithApple(
                        script: self.latestScript,
                        userPrompt: userText
                    )
                    
                    self.handleBotReply(reply, source: "apple")
                    
                    
                case .generateDescription:
                    print("🍎 routing to apple (description)")
                    
                    let reply = try await generateDescriptionWithApple(
                        script: self.latestScript,
                        userPrompt: userText
                    )
                    
                    self.handleBotReply(reply, source: "apple")
                    
                    
                case .chat:
                    let prompt = """
                    You are a friendly, casual AI assistant.
                    You are allowed to chat freely, respond naturally, and talk about everyday topics.
                    
                    User message:
                    \(userText)
                    """
                    
                    let reply = try await AppleIntelligenceManager.shared.askSafely(prompt: prompt)
                    self.handleBotReply(reply, source: "apple")
                    
                }
                
            } catch {
                self.handleBotReply(
                    "I couldn’t understand that request. Try rephrasing.",
                    source: "system"
                )
            }
        }
        
    }
    
    
    func handleBotReply(_ replyText: String?, source: String) {
        
        
        if let replyText {
            Task {
                do {
                    _ = try await controller.addChatMessage(
                        id: conversationID!,
                        sender: .bot,
                        content: replyText
                    )
                    print("✅ Bot message saved")
                } catch {
                    print("❌ Failed to save bot message:", error)
                }
            }
        }
        
        
        // 🔹 UI updates on main thread (unchanged)
        DispatchQueue.main.async {
            
            // Remove "Thinking..."
            if !self.messages.isEmpty {
                self.messages.removeLast()
            }
            
            guard let replyText else {
                self.messages.append(
                    Message(role: "bot", content: "Something went wrong.")
                )
                self.tableView.reloadData()
                self.scrollToBottom()
                return
            }
            
            self.messages.append(
                Message(role: "bot", content: replyText)
            )
            
            self.tableView.reloadData()
            self.scrollToBottom()
        }
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
            let isMarked = message.mark == type
            if !isMarked && isTypeAlreadyMarked(type) {
                return
            }
            
            let title = isMarked ? "Unmark \(type.capitalized)" : "Mark as \(type.capitalized)"
            
            alert.addAction(UIAlertAction(title: title, style: .default) { _ in
                if isMarked {
                    message.mark = nil
                    self.markedMessages[type]?.removeAll {
                        $0.content == message.content
                    }
                    self.didShowFinalReadyMessage = false
                    self.showScriptSuggestions()
                    
                } else {
                    if let oldType = message.mark {
                        self.markedMessages[oldType]?.removeAll { $0.content == message.content }
                    }
                    
                    self.generateStack.isHidden = false
                    message.mark = type
                    self.markedMessages[type]?.append(message)
                    
                    if let chatID = self.conversationID {
                        Task {
                            do {
                                try await self.controller.upsertScriptField(
                                    chatID: chatID,
                                    field: type,
                                    value: message.content
                                )
                                print(" Saved \(type) to scripted_ideas")
                            } catch {
                                print(" Failed to save \(type):", error)
                            }
                        }
                    }
                    
                    if self.isAllContentMarked() && !self.didShowFinalReadyMessage {
                        
                        self.didShowFinalReadyMessage = true
                        
                        let finalMessage = Message(
                            role: "bot",
                            content: "less goo your post is ready"
                        )
                        
                        self.messages.append(finalMessage)
                        
                        let indexPath = IndexPath(
                            row: self.messages.count - 1,
                            section: 0
                        )
                        
                        self.tableView.insertRows(at: [indexPath], with: .fade)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                    
                    
                    switch type {
                    case "script":
                        self.showScriptSuggestions()
                    case "title":
                        self.showScriptSuggestions()
                    case "description":
                        self.showScriptSuggestions()
                    case "thumbnail":
                        self.showScriptSuggestions()
                        
                    default:
                        self.showScriptSuggestions()
                    }
                }
                self.messages[row] = message
                self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
            })
        }
        
        ["script", "title", "description", "thumbnail"].forEach { addMarkAction(type: $0) }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
        
    }
    
    
    func getUnmarkedTypes() -> [String] {
        return requiredMarkTypes.filter { type in
            markedMessages[type]?.isEmpty ?? true
        }
    }
    
    func showScriptSuggestions() {
        
        // Remove previous buttons
        generateStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Get only the types which are not marked
        let unmarkedTypes = getUnmarkedTypes()
        
        if unmarkedTypes.isEmpty {
            generateStack.isHidden = true
            return
        }
        
        generateStack.isHidden = false
        
        for type in unmarkedTypes {
            
            let buttonTitle: String
            
            switch type {
            case "script":
                buttonTitle = "Generate Script"
            case "title":
                buttonTitle = "Generate Title"
            case "description":
                buttonTitle = "Generate Description"
            case "thumbnail":
                buttonTitle = "Generate Thumbnail"
            default:
                continue
            }
            
            if let view = Bundle.main
                .loadNibNamed("SuggestionCell", owner: self)?
                .first as? SuggestionCell {
                
                view.generateButton.setTitle(buttonTitle, for: .normal)
                view.generateButton.addTarget(
                    self,
                    action: #selector(generateButtonTapped(_:)),
                    for: .touchUpInside
                )
                
                generateStack.addArrangedSubview(view)
            }
        }
        
        generateStack.layoutIfNeeded()
    }
    
    
    @objc func generateButtonTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        sendMessage(title)
        generateStack.isHidden = true
    }
    
    func didTapDraftScript(for idea: Idea) {
        
        sendAutoMessage("script")
        
        if let lastIndex = messages.indices.last {
            messages[lastIndex].mark = "script"
        }
        
        generateStack.isHidden = false
        showScriptSuggestions()
    }
    
    func sendAutoMessage(_ text: String) {
        messages.append(Message(role: "user", content: text))
        tableView.reloadData()
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
}
