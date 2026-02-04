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

    @IBOutlet weak var inputViewBottomConstraint: NSLayoutConstraint!
    
    
    let dbController = ScriptedIdeasController() // Initialize your controller
    var currentActiveScript: ScriptedIdea?


    @IBOutlet weak var scriptedChats: UIBarButtonItem!

    var messages: [Message] = []
    var autoSendMessage: String?

    let botDatabase: [String: String] = [
        "hi": "hello",
        "hello": "Hi! How can I help you today?",
        "script": "Real beauty isn’t about perfection.It’s about embracing who you are—your skin, your smile, your story.Every freckle, every flaw, every feature makes you unique.",
        "generate title": "Real Beauty, Real Confidence",
        "generate thumbnail": "Your thumbnail here",
        "generate description": "Real Beauty, Real Confidence.Real beauty isn’t about perfection.",
        "description": "Real Beauty, Real Confidence.Real beauty isn’t about perfection.",
        "generate script": "Real beauty isn’t about perfection.It’s about embracing who you are—your skin, your smile, your story.Every freckle, every flaw, every feature makes you unique.",
        "idea": "You can make a beauty product review",
        "title": "Real Beauty, Real Confidence",
        "default": "Sorry, I don't understand. Could you rephrase that?"
    ]

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
            messages.append(Message(text: welcomeMessage, isUser: false))
            tableView.reloadData()
            scrollToBottom()
        }
    }


    @IBAction func scriptView(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ViewScripts", bundle: nil)
        guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController else {return}
        guard let destinationVC = navVC.topViewController as? ViewScriptsViewController else {return}
        destinationVC.pageTitle = "Your Scripts"
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

//    func sendMessage(_ text: String) {
//        messages.append(Message(text: text, isUser: true))
//        tableView.reloadData()
//
//        let indexPath = IndexPath(row: messages.count - 1, section: 0)
//        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//
//        textFieldView.text = ""
//        textViewDidChange(textFieldView)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.generateBotReply(for: text)
//                }
//    }

    
    func sendMessage(_ text: String) {
            // 1. Update UI
            messages.append(Message(text: text, isUser: true))
            tableView.reloadData()
            
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)

            textFieldView.text = ""
            textViewDidChange(textFieldView)

            // 2. NEW: Database Check (Live Phase)
            // If we have an ID (meaning the user has already marked a script), save this message now.
            if let scriptID = currentActiveScript?.id {
                Task {
                    print("☁️ Saving user message to DB...")
                    try? await dbController.saveChatMessage(ideaID: scriptID, text: text, isUser: true)
                }
            }

            // 3. Generate Reply
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.generateBotReply(for: text)
            }
        }
    
    
        func generateBotReply(for userText: String) {
            
            // 1. UI: Add temporary "Thinking..." message
            let loadingMessage = Message(text: "Thinking...", isUser: false)
            messages.append(loadingMessage)
            tableView.reloadData()
            scrollToBottom()
            
            // 2. Logic: Customize prompt based on user intention
            var prompt = userText
            let lower = userText.lowercased()
            
            if lower.contains("generate title") {
                 // We need to send context if we want a title for a specific script.
                 // For now, let's assume the user just pasted the script or is asking generally.
                 // Ideally, you'd append the previous bot message here.
                 prompt = "Generate a catchy title for a script about: \(userText)"
            }
            
            // 3. Call your Edge Function via the Manager
            GeminiManager.shared.generateContent(prompt: prompt) { [weak self] responseText in
                guard let self = self else { return }
                
                // Remove "Thinking..."
                if !self.messages.isEmpty {
                    self.messages.removeLast()
                }
                
                // Add actual response
                let finalText = responseText ?? "Sorry, I couldn't connect to the server."
                self.messages.append(Message(text: finalText, isUser: false))
                
                if let scriptID = self.currentActiveScript?.id {
                    Task {
                        print("☁️ Saving AI message to DB...")
                        try? await self.dbController.saveChatMessage(ideaID: scriptID, text: finalText, isUser: false)
                    }
                }
                
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
        // 1. Trigger action only when the press begins
        guard gesture.state == .began else { return }
        guard let cellView = gesture.view else { return }
        let row = cellView.tag
        var message = messages[row]
        
        
//        var sheetTitle = "Options"
//        if let type = message.markType {
//            sheetTitle = "Manage \(type.capitalized)"
//        } else {
//            sheetTitle = "Select Option"
//        }
        
        // 2. Create Alert Controller (ActionSheet style)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // 3. Define the Helper Function to add actions
        func addMarkAction(type: String) {
            let isMarked = message.markType == type
            
            // If this type is already taken by another message, don't show the button
            if !isMarked && isTypeAlreadyMarked(type) {
                return
            }

            let title = isMarked ? "Unmark \(type.capitalized)" : "Mark as \(type.capitalized)"
            
            // Use Red (.destructive) for Unmark, Blue (.default) for Mark
            let style: UIAlertAction.Style = isMarked ? .destructive : .default
            
            alert.addAction(UIAlertAction(title: title, style: style) { _ in
                if isMarked {
                    // --- UNMARK LOGIC ---
                    message.markType = nil
                    
                    self.markedMessages[type]?.removeAll {
                        $0.text == message.text
                    }
                    
                    // Sync to DB (Set to NULL)
                    self.syncToDatabase(type: type, text: nil)
                    
                    self.didShowFinalReadyMessage = false
                    self.showScriptSuggestions()

                } else {
                    // --- MARK LOGIC ---
                    // Safety: If it was marked as something else before, clear that old type
                    if let oldType = message.markType {
                        self.markedMessages[oldType]?.removeAll { $0.text == message.text }
                    }

                    self.generateStack.isHidden = false
                    message.markType = type
                    self.markedMessages[type]?.append(message)
                    
                    // Sync to DB (Set to Value)
                    self.syncToDatabase(type: type, text: message.text)
                    
                    // Check if the set is complete
                    if self.isAllContentMarked() && !self.didShowFinalReadyMessage {
                        self.didShowFinalReadyMessage = true
                        
                        let finalMessage = Message(
                            text: "less goo your post is ready",
                            isUser: false
                        )
                        
                        self.messages.append(finalMessage)
                        
                        let indexPath = IndexPath(
                            row: self.messages.count - 1,
                            section: 0
                        )
                        
                        self.tableView.insertRows(at: [indexPath], with: .fade)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                    
                    self.showScriptSuggestions()
                }
                
                // Update the specific row to reflect UI changes (like highlighting)
                self.messages[row] = message
                self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
            })
        }

        // 4. Decide which buttons to show
        if let currentMarkType = message.markType {
            // Case 1: Already Marked -> Only show the "Unmark" option
            addMarkAction(type: currentMarkType)
        } else {
            // Case 2: Not Marked -> Show all available options
            ["script", "title", "description", "thumbnail"].forEach { addMarkAction(type: $0) }
        }

        // 5. Add Cancel Button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // 6. iPad Crash Fix
        // Only apply popover settings if the device is actually an iPad.
        // This ensures iPhones still use the bottom sheet (Stacked) look.
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = cellView
                popoverController.sourceRect = cellView.bounds
                popoverController.permittedArrowDirections = .any
            }
        }
        
        // 7. Present the Menu
        self.present(alert, animated: true)
    }
    
    
    // Add this function to Chatbot class
    // MARK: - Database Logic
        func syncToDatabase(type: String, text: String?) {
            Task {
                do {
                    // SCENARIO 1: Creating a new script (Must have text, can't be nil)
                    if type == "script", let validText = text, currentActiveScript == nil {
                        print("🆕 Creating new script in Supabase...")
                        
                        // 1. Create the Idea Card
                        let newScript = try await dbController.addScript(scriptContent: validText)
                        self.currentActiveScript = newScript
                        print("✅ Created Script ID: \(newScript.id)")
                        
                        // 2. NEW: Save all the chat history we have so far!
                        // We link the existing 'messages' array to this new Idea ID.
                        print("💾 Saving chat history buffer...")
                        try await dbController.batchSaveMessages(ideaID: newScript.id, messages: self.messages)
                        print("✅ Chat history saved!")
                        
                    }
                    // SCENARIO 2: Updating (or Unmarking) an existing script
                    else if var scriptToUpdate = currentActiveScript {
                        print("🔄 Updating existing script...")
                        
                        // If text is nil (Unmark), the property becomes nil
                        switch type {
                        case "script": scriptToUpdate.script = text
                        case "title": scriptToUpdate.title = text
                        case "description": scriptToUpdate.description = text
                        case "thumbnail": scriptToUpdate.thumbnailURL = text
                        default: break
                        }
                        
                        // Send update to Supabase
                        let updated = try await dbController.updateScript(scriptToUpdate)
                        self.currentActiveScript = updated
                        
                        if text == nil {
                            print("🗑 Unmarked (Set to NULL): \(type)")
                        } else {
                            print("✅ Update Successful: \(type)")
                        }
                    }
                } catch {
                    print("❌ Database Error: \(error)")
                }
            }
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
            messages[lastIndex].markType = "script"
        }

        generateStack.isHidden = false
        showScriptSuggestions()
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
