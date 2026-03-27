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
    var selectedPlatform: String?
    var ideaMilestone: Int = 0
    var ideaId: UUID?
    let controller = ScriptedIdeasController()
    private var progressHeader: ProgressCell?
    var markedMessages: [String: [Message]] = [
        "script": [],
        "title": [],
        "description": [],
        "thumbnail": []
    ]
    
    let maxLines: CGFloat = 10
    let minLines: CGFloat = 3
    let lineHeight: CGFloat = 100
    let requiredMarkTypes = ["script", "title", "description"]
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
        tableView.contentInset = UIEdgeInsets(top: 125, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 125, left: 0, bottom: 0, right: 0)

        generateStack.isHidden = true
        tableView.register(
            UINib(nibName: "PlatformCellTableViewCell", bundle: nil),
            forCellReuseIdentifier: "PlatformCell"
        )

        tableView.sectionHeaderTopPadding = 0
        let header = Bundle.main.loadNibNamed("ProgressCell", owner: self, options: nil)?.first as! ProgressCell

        header.configure(completedTypes: [])
        header.translatesAutoresizingMaskIntoConstraints = false
        header.onViewIdeaTapped = { [weak self] in
            self?.navigateToViewIdea()
        }

        view.addSubview(header)
        progressHeader = header

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            header.heightAnchor.constraint(equalToConstant: 125),
        ])

        if conversationID == nil {
            
            conversationID = UUID()
            print("New Conversation started:", conversationID!)
            
            Task {
                do {
                    _ = try await controller.addConversation(id: conversationID ?? UUID(), ideaId: ideaId)
                    print("Conversation created")
                } catch {
                    print("Failed to create conversation:", error)
                }
            }
            
        } else {
            print("📌 Opening existing conversation:", conversationID!)
        }
        
        Task {
            do {
                let history = try await controller.fetchMessages(for: conversationID ?? UUID())
                let allIdeas = try await controller.fetchScript()
                let idea = allIdeas.first { $0.chat_id == self.conversationID }
                
                let mapped = history.map { chat in
                    
                    var message = Message(
                        role: chat.role.rawValue,
                        content: chat.content,
                        mark: nil
                    )
                    
                    guard let idea else { return message }
                    
                    if chat.content == idea.script {
                        message.mark = "script"
                    } else if chat.content == idea.title {
                        message.mark = "title"
                    } else if chat.content == idea.description {
                        message.mark = "description"
                    }
                    
                    return message
                }
                await MainActor.run {

                    if !mapped.isEmpty {
                        self.messages = mapped
                    }

                    if let idea = idea {
                        if let script = idea.script, !script.isEmpty {
                            self.markedMessages["script"] = [Message(role: "bot", content: script, mark: "script")]
                        }
                        if let title = idea.title, !title.isEmpty {
                            self.markedMessages["title"] = [Message(role: "bot", content: title, mark: "title")]
                        }
                        if let description = idea.description, !description.isEmpty {
                            self.markedMessages["description"] = [Message(role: "bot", content: description, mark: "description")]
                        }

                        self.updateProgressHeader()
                    }

                    self.tableView.reloadData()
                    self.scrollToBottom()

                    if let text = self.autoSendMessage {
                        self.sendMessage(text)
                        self.autoSendMessage = nil
                    }
                }

            } catch {
                print(" Failed loading conversation:", error)
            }
        }
        
        
        setupKeyboardObservers()
        setupTapToDismiss()
    }

    private func navigateToViewIdea() {
        Task {
            do {
                let allIdeas = try await controller.fetchScript()
                guard let idea = allIdeas.first(where: { $0.chat_id == self.conversationID }) else {
                    print("No scripted idea found for this conversation")
                    return
                }
                await MainActor.run {
                    let storyboard = UIStoryboard(name: "Ideate", bundle: nil)
                    guard let vc = storyboard.instantiateViewController(withIdentifier: "scriptedIdea") as? ScriptedIdeas else { return }
                    vc.idea = idea
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } catch {
                print("Failed to fetch scripted idea:", error)
            }
        }
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
            let indexPath = IndexPath(row: messages.count, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "PlatformCell",
                for: indexPath
            ) as! PlatformCellTableViewCell
            cell.onPlatformSelected = { [weak self] platform in
                guard let self = self, let id = self.conversationID else { return }
                self.selectedPlatform = platform
                Task {
                    do {
                        try await self.controller.updatePlatform(id: id, platform: platform)
                        print("Platform saved:", platform)
                    } catch {
                        print("Failed to save platform:", error)
                    }
                }
            }
            return cell
        }
        
        
        let messageIndex = indexPath.row - 1


        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        cell.configure(with: messages[messageIndex])
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        cell.contentView.addGestureRecognizer(longPress)
        cell.contentView.tag = messageIndex
        
        return cell
        
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
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
        
        // Decide intent & route
        Task { [weak self] in
            guard let self = self else { return }
            
            let intent = await AIResponseRouter.shared.classifyIntent(
                message: userText,
                conversationID: conversationID,
                platform: selectedPlatform
            )
            
            print(intent)
            let platform = selectedPlatform ?? "general"
            
            switch intent {
                
            case .generateScript:
                print("routing to gemini")
                
                GeminiManager.shared.generateContent(
                    prompt: "\(userText)\nWrite this for \(selectedPlatform ?? "general") audience.",
                    conversationID: conversationID ?? UUID()
                ) { reply in
                    self.latestScript = reply
                    self.handleBotReply(reply, source: "gemini")
                }
                
            case .generateTitle:
                let reply = await generateTitleWithApple(
                    script: self.latestScript,
                    userPrompt: "\(userText)\nPlatform: \(platform). Write a title optimized for \(platform).",
                    conversationID: conversationID
                )
                
                self.handleBotReply(reply, source: "auto")
                
            case .generateDescription:
                let reply = await generateDescriptionWithApple(
                    script: self.latestScript,
                    userPrompt: "\(userText)\nPlatform: \(platform). Write a description optimized for \(platform).",
                    conversationID: conversationID
                )
                
                self.handleBotReply(reply, source: "auto")
                
            case .chat:
                let prompt = """
                    You are a friendly, casual AI assistant helping create content for \(platform).
                    Keep responses relevant to \(platform) where applicable.
                
                User message:
                \(userText)
                """
                
                let reply = await AIResponseRouter.shared.respond(
                    intent: .chat,
                    prompt: prompt,
                    conversationID: conversationID
                )
                
                self.handleBotReply(reply, source: "auto")
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
                    
                    try await controller.generateAndStoreTitleIfNeeded(
                        conversationID: conversationID!
                    )
                } catch {
                    print("❌ Failed to save bot message:", error)
                }
            }
        }
        
        
        // UI updates on main thread (unchanged)
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
                    self.updateProgressHeader()
                    if let chatID = self.conversationID {
                        Task {
                            do {
                                try await self.controller.upsertScriptField(
                                    chatID: chatID,
                                    field: type,
                                    value: ""
                                )
                                print("🗑️ Removed \(type) from scripted_ideas")
                            } catch {
                                print("❌ Failed to remove \(type):", error)
                            }
                        }
                    }
                    
                } else {
                    if let oldType = message.mark {
                        self.markedMessages[oldType]?.removeAll { $0.content == message.content }
                    }
                    
                    self.generateStack.isHidden = false
                    message.mark = type
                    self.markedMessages[type]?.append(message)
                    self.updateProgressHeader()
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

                        let indexPath = IndexPath(row: self.messages.count, section: 0)

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
                self.tableView.reloadRows(at: [IndexPath(row: row + 1, section: 0)], with: .none)
            })
        }
        
        ["script", "title", "description"].forEach { addMarkAction(type: $0) }
        
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

    private func updateProgressHeader() {
        let completedTypes = Set(requiredMarkTypes.filter {
            !(markedMessages[$0]?.isEmpty ?? true)
        })
        progressHeader?.configure(completedTypes: completedTypes)
    }

}

