//
//  Chatbot.swift
//  Hushtag
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit
import FoundationModels
import NaturalLanguage


class Chatbot: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, LikedCellDelegate {
    func didToggleLike(for ideaId: UUID) {
        ""
    }


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
        
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScriptDeletion(_:)),
            name: .scriptDeleted,
            object: nil
        )
        
        // --- NEW: Check for existing script and load history ---
        if let script = currentActiveScript {
                    print("📜 Loading history for script: \(script.id)")
                    // Pass the ENTIRE script object so we can mark things after loading
                    loadChatHistory(using: script)
                } else {
                    // New Chat Setup
                    if messages.isEmpty {
                        let welcomeMessage = "Welcome! I’m your scripting assistant. Lets write a script for you."
                        messages.append(Message(text: welcomeMessage, isUser: false))
                        tableView.reloadData()
                        scrollToBottom()
                    }
                }

        setupKeyboardObservers()
        setupTapToDismiss()
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: SCRIPT DELETION
    
    @objc func handleScriptDeletion(_ notification: Notification) {
        // 1. Check if we have an active script
        guard let currentID = currentActiveScript?.id else { return }
        
        // 2. Check if the deleted ID matches our active ID
        guard let deletedID = notification.userInfo?["deletedID"] as? UUID,
              deletedID == currentID else {
            return
        }
        
        // 3. Reset on Main Thread
        DispatchQueue.main.async { [weak self] in
            print("🗑 Current script was deleted. Resetting chat...")
            self?.resetToNewChat()
        }
    }
    
    func resetToNewChat() {
        // 1. Clear Data Models
        self.currentActiveScript = nil
        self.messages.removeAll()
        self.markedMessages = [
            "script": [],
            "title": [],
            "description": [],
            "thumbnail": []
        ]
        
        // 2. Add Welcome Message
        let welcomeMessage = "Welcome! I’m your scripting assistant. Lets write a script for you."
        self.messages.append(Message(text: welcomeMessage, isUser: false))
        
        // 3. Reset UI
        self.generateStack.isHidden = true
        self.tableView.reloadData()
        
        // 4. Reset Text Input (Optional)
        self.textFieldView.text = ""
        self.textViewDidChange(self.textFieldView)
    }
    
    
    
    // MARK: - History Loading (Fixed)
        func loadChatHistory(using script: ScriptedIdea) {
            Task {
                do {
                    // 1. Fetch from Supabase
                    let history = try await dbController.fetchChatHistory(for: script.id)
                    
                    await MainActor.run {
                        // 2. Populate the messages array FIRST
                        self.messages = history
                        
                        // 3. NOW it is safe to run restoration because 'self.messages' is not empty
                        self.restoreMarkedState(from: script)
                        
                        // 4. Reload and scroll
                        self.tableView.reloadData()
                        
                        if !self.messages.isEmpty {
                            self.scrollToBottom()
                        }
                    }
                } catch {
                    print("Error loading history: \(error)")
                }
            }
        }
    
    
    // MARK: - Restore Selection State
        func restoreMarkedState(from script: ScriptedIdea) {
            print("Bot: Restoring marked state...")
            
            // Clear previous states to be safe
            markedMessages = ["script": [], "title": [], "description": [], "thumbnail": []]
            
            for i in messages.indices {
                // Normalize strings to ensure matches work even with accidental spaces
                let msgText = messages[i].text.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // 1. Check Title
                if let title = script.title?.trimmingCharacters(in: .whitespacesAndNewlines), msgText == title {
                    messages[i].markType = "title"
                    markedMessages["title"] = [messages[i]]
                }
                // 2. Check Description
                else if let desc = script.description?.trimmingCharacters(in: .whitespacesAndNewlines), msgText == desc {
                    messages[i].markType = "description"
                    markedMessages["description"] = [messages[i]]
                }
                // 3. Check Script
                else if let sBody = script.script?.trimmingCharacters(in: .whitespacesAndNewlines), msgText == sBody {
                    messages[i].markType = "script"
                    markedMessages["script"] = [messages[i]]
                }
                // 4. Check Thumbnail
                else if let thumb = script.thumbnailURL?.trimmingCharacters(in: .whitespacesAndNewlines), msgText == thumb {
                    messages[i].markType = "thumbnail"
                    markedMessages["thumbnail"] = [messages[i]]
                }
            }
            
            // Update the UI
            showScriptSuggestions()
            // Note: tableView.reloadData() is called by the parent function immediately after this returns
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

    


    @IBAction func scriptView(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ViewScripts", bundle: nil)
        guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController else {return}
        guard let destinationVC = navVC.topViewController as? ViewScriptsViewController else {return}
        destinationVC.pageTitle = "Your Scripts"
        self.navigationController?.pushViewController(destinationVC, animated: true)

        
    }

    
    //MARK: KEYBOARD DISMISS

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
    
    
    //MARK: TABLE VIEW FUNCTIONS

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
    
    
    //MARK: MESSAGE SENDING

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
        var prompt = text
        if prompt.lowercased().contains("generate title"){
            prompt = """
            GENERATE TITLE - 
                
            Generate a catchy, short title for the script.
            """
        }else if prompt.lowercased().contains("generate description"){
            prompt = """
            GENERATE DESCRIPTION -
                                    
            Generate description a short, engaging description (2 sentences max) for the script.
            """
        }
            messages.append(Message(text: prompt, isUser: true))
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
    
    
//    func generateBotReply(for userText: String) {
//            // UI: "Thinking..."
//            let loadingMessage = Message(text: "Thinking...", isUser: false)
//            messages.append(loadingMessage)
//            tableView.reloadData()
//            scrollToBottom()
//            
//            // --- LOGIC: Context Injection ---
//            // If the user asks for Title/Description, we inject the marked script into the prompt.
//            var prompt = userText
//            let lower = userText.lowercased()
//            
//            // Check if we have a marked script to base the generation on
//            let scriptContext = markedMessages["script"]?.first?.text ?? ""
//            
//            if !scriptContext.isEmpty {
//                if lower.contains("generate title") || lower.contains("suggest title") {
//                    prompt = "Generate a catchy, short title for the following script:\n\n\(scriptContext)"
//                } else if lower.contains("generate description") {
//                    prompt = "Generate a short, engaging description (2 sentences max) for the following script:\n\n\(scriptContext)"
//                } else if lower.contains("generate thumbnail") {
//                    prompt = "Describe a visual thumbnail image that would represent this script:\n\n\(scriptContext)"
//                }
//            }
//            
//            // --- CALL MANAGER ---
//            Task {
//                var responseText: String?
//                
//                // 1. Try Apple Intelligence
//                if #available(iOS 18.0, *), AppleIntelligenceManager.shared.isAvailable {
//                    do {
//                        print("🧠 Asking Apple Intelligence...")
//                        responseText = try await AppleIntelligenceManager.shared.ask(prompt: prompt)
//                    } catch {
//                        print("⚠️ Apple AI failed: \(error). Falling back.")
//                    }
//                }
//                
//                // 2. Fallback to Gemini (if Apple failed or unavailable)
//                if responseText == nil {
//                    print("✨ Asking Gemini (Fallback)...")
//                    await withCheckedContinuation { continuation in
//                        GeminiManager.shared.generateContent(prompt: prompt) { result in
//                            responseText = result
//                            continuation.resume()
//                        }
//                    }
//                }
//                
//                // 3. Update UI
//                await MainActor.run {
//                    if !self.messages.isEmpty { self.messages.removeLast() } // Remove "Thinking..."
//                    
//                    let finalContent = responseText ?? "Sorry, I couldn't connect to the server."
//                    self.messages.append(Message(text: finalContent, isUser: false))
//                    
//                    if let scriptID = self.currentActiveScript?.id {
//                        Task { try? await self.dbController.saveChatMessage(ideaID: scriptID, text: finalContent, isUser: false) }
//                    }
//                    
//                    self.tableView.reloadData()
//                    self.scrollToBottom()
//                }
//            }
//        }
    
    
    //MARK: AI PROMPT AND REPLY FUNCTIONS
    
    func generateBotReply(for userText: String) {
            let loadingMessage = Message(text: "Thinking...", isUser: false)
            messages.append(loadingMessage)
            tableView.reloadData()
            scrollToBottom()
            
            let lower = userText.lowercased()
            
            // 1. Check for Context (Is the user asking based on a selected script?)
            let scriptContext = markedMessages["script"]?.first?.text ?? ""
            
            // ROUTING LOGIC:
            // If "Generate Title/Description/Thumbnail" -> Use Hybrid (Apple First)
            // Everything else (Scripts, Chat, Advice) -> Use Gemini Only
            
            if !scriptContext.isEmpty && (lower.contains("generate title") || lower.contains("suggest title")) {
                let prompt = """
                    GENERATE TITLE - 
                    
                    You are a professional YouTube content creator and have high engagement rate on the platform with subcribers in hundredths of thousands. Generate a catchy, short title for the following script which will be SEO optimased and give higher engagement rate on a video for this script.
                    Format it strictly as:
                    TITLE: [Title]
                
                    Script:
                    \(scriptContext)
                """
                performHybridGeneration(prompt: prompt)
                
            } else if !scriptContext.isEmpty && lower.contains("generate description") {
                let prompt = """
                    GENERATE DESCRIPTION -
                    
                    Generate a short, engaging description (2 sentences max) for the following script.
                    Format it strictly as:
                    DESC: [Description]
                    
                    Script:
                    \(scriptContext)
                """
                performHybridGeneration(prompt: prompt)
                
            } else if !scriptContext.isEmpty && lower.contains("generate thumbnail") {
                let prompt = "Describe a visual thumbnail image that would represent this script:\n\n\(scriptContext)"
                performHybridGeneration(prompt: prompt)
                
            } else {
                // Default Case: Generating Scripts or General Chat
                // User requested: "Script should get generated from Gemini only"
                performGeminiGeneration(prompt: userText)
            }
        }
        
        // MARK: - Generation Strategy 1: Gemini ONLY
        // Used for Scripts and General Chat
        func performGeminiGeneration(prompt: String) {
            print("✨ Routing to Gemini (Direct)...")
            
            GeminiManager.shared.generateContent(prompt: prompt) { [weak self] responseText in
                guard let self = self else { return }
                self.handleAIResponse(responseText)
            }
        }
        
        // MARK: - Generation Strategy 2: Hybrid (Apple -> Gemini Fallback)
        // Used for Titles, Descriptions, and Summaries
        func performHybridGeneration(prompt: String) {
            print("🧠 Routing to Hybrid (Apple First)...")
            
            Task {
                var responseText: String?
                
                // Step A: Try Apple Intelligence
                if #available(iOS 18.0, *), AppleIntelligenceManager.shared.isAvailable {
                    do {
                        responseText = try await AppleIntelligenceManager.shared.ask(prompt: prompt)
                        print("✅ Apple Intelligence responded.")
                    } catch {
                        print("⚠️ Apple AI failed: \(error). Falling back.")
                    }
                }
                
                // Step B: Fallback to Gemini if Apple failed
                if responseText == nil {
                    print("✨ Apple unavailable/failed. Asking Gemini...")
                    await withCheckedContinuation { continuation in
                        GeminiManager.shared.generateContent(prompt: prompt) { result in
                            responseText = result
                            continuation.resume()
                        }
                    }
                }
                
                // Step C: Handle Result
                await MainActor.run {
                    self.handleAIResponse(responseText)
                }
            }
        }
        
        // Shared Response Handler
        private func handleAIResponse(_ text: String?) {
            // Remove "Thinking..."
            if !self.messages.isEmpty { self.messages.removeLast() }
            
            let finalContent = text ?? "Sorry, I couldn't connect to the server."
            var cleanContent = finalContent
            
            let plainText = finalContent.replacingOccurrences(of: "*", with: "")
            
            //print(text ?? "EMPTY")
            
            
            let trimmed = plainText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmed.uppercased().hasPrefix("TITLE:") {
                // Remove "TITLE:" and trim spaces
                cleanContent = trimmed
                    .replacingOccurrences(of: "TITLE:", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            }
            else if trimmed.uppercased().hasPrefix("DESC:") {
                // Remove "DESC:" and trim spaces
                cleanContent = trimmed
                    .replacingOccurrences(of: "DESC:", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            }
            else{
                cleanContent = finalContent.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            //print(cleanContent)
            
            self.messages.append(Message(text: cleanContent, isUser: false))
            
            if let scriptID = self.currentActiveScript?.id {
                Task { try? await self.dbController.saveChatMessage(ideaID: scriptID, text: cleanContent, isUser: false) }
            }
            
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    


    @IBAction func sendButton(_ sender: Any) {
        let text = textFieldView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                sendMessage(text)
            }
    }

//    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
//        // 1. Trigger action only when the press begins
//        guard gesture.state == .began else { return }
//        guard let cellView = gesture.view else { return }
//        let row = cellView.tag
//        var message = messages[row]
//        
//        
////        var sheetTitle = "Options"
////        if let type = message.markType {
////            sheetTitle = "Manage \(type.capitalized)"
////        } else {
////            sheetTitle = "Select Option"
////        }
//        
//        // 2. Create Alert Controller (ActionSheet style)
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//        // 3. Define the Helper Function to add actions
//        func addMarkAction(type: String) {
//            let isMarked = message.markType == type
//            
//            // If this type is already taken by another message, don't show the button
//            if !isMarked && isTypeAlreadyMarked(type) {
//                return
//            }
//
//            let title = isMarked ? "Unmark \(type.capitalized)" : "Mark as \(type.capitalized)"
//            
//            // Use Red (.destructive) for Unmark, Blue (.default) for Mark
//            let style: UIAlertAction.Style = isMarked ? .destructive : .default
//            
//            alert.addAction(UIAlertAction(title: title, style: style) { _ in
//                if isMarked {
//                    // --- UNMARK LOGIC ---
//                    message.markType = nil
//                    
//                    self.markedMessages[type]?.removeAll {
//                        $0.text == message.text
//                    }
//                    
//                    // Sync to DB (Set to NULL)
//                    self.syncToDatabase(type: type, text: nil)
//                    
//                    self.didShowFinalReadyMessage = false
//                    self.showScriptSuggestions()
//
//                } else {
//                    // --- MARK LOGIC ---
//                    // Safety: If it was marked as something else before, clear that old type
//                    if let oldType = message.markType {
//                        self.markedMessages[oldType]?.removeAll { $0.text == message.text }
//                    }
//
//                    self.generateStack.isHidden = false
//                    message.markType = type
//                    self.markedMessages[type]?.append(message)
//                    
//                    // Sync to DB (Set to Value)
//                    self.syncToDatabase(type: type, text: message.text)
//                    
//                    // Check if the set is complete
//                    if self.isAllContentMarked() && !self.didShowFinalReadyMessage {
//                        self.didShowFinalReadyMessage = true
//                        
//                        let finalMessage = Message(
//                            text: "less goo your post is ready",
//                            isUser: false
//                        )
//                        
//                        self.messages.append(finalMessage)
//                        
//                        let indexPath = IndexPath(
//                            row: self.messages.count - 1,
//                            section: 0
//                        )
//                        
//                        self.tableView.insertRows(at: [indexPath], with: .fade)
//                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//                    }
//                    
//                    self.showScriptSuggestions()
//                }
//                
//                // Update the specific row to reflect UI changes (like highlighting)
//                self.messages[row] = message
//                self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
//            })
//        }
//
//        // 4. Decide which buttons to show
//        if let currentMarkType = message.markType {
//            // Case 1: Already Marked -> Only show the "Unmark" option
//            addMarkAction(type: currentMarkType)
//        } else {
//            // Case 2: Not Marked -> Show all available options
//            ["script", "title", "description", "thumbnail"].forEach { addMarkAction(type: $0) }
//        }
//
//        // 5. Add Cancel Button
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        
//        // 6. iPad Crash Fix
//        // Only apply popover settings if the device is actually an iPad.
//        // This ensures iPhones still use the bottom sheet (Stacked) look.
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            if let popoverController = alert.popoverPresentationController {
//                popoverController.sourceView = cellView
//                popoverController.sourceRect = cellView.bounds
//                popoverController.permittedArrowDirections = .any
//            }
//        }
//        
//        // 7. Present the Menu
//        self.present(alert, animated: true)
//    }
    
    
    
    //MARK: LONG PRESS GESTURE FUNCTION
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else { return }
            guard let cellView = gesture.view else { return }
            let row = cellView.tag
            
            var message = messages[row]
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            // LOGIC: Strict separation.
            // If marked -> ONLY Unmark.
            // If not marked -> ONLY Mark options.
            
            if let currentType = message.markType {
                // --- UNMARK OPTION ---
                let title = "Unmark \(currentType.capitalized)"
                let unmarkAction = UIAlertAction(title: title, style: .destructive) { _ in
                    
                    // 1. Update UI Model
                    message.markType = nil
                    self.messages[row] = message // Update array
                    
                    // 2. Clear Internal Dictionary
                    self.markedMessages[currentType]?.removeAll { $0.text == message.text }
                    
                    // 3. Sync to Database (Set column to NULL)
                    self.syncToDatabase(type: currentType, text: nil)
                    
                    // 4. Refresh UI
                    self.didShowFinalReadyMessage = false
                    self.showScriptSuggestions()
                    self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                }
                alert.addAction(unmarkAction)
                
            } else {
                // --- MARK OPTIONS ---
                for type in requiredMarkTypes {
                    // If "Title" is already assigned to a DIFFERENT message, don't show it here.
                    if isTypeAlreadyMarked(type) { continue }
                    
                    let title = "Mark as \(type.capitalized)"
                    let action = UIAlertAction(title: title, style: .default) { _ in
                        
                        // 1. Update UI Model
                        message.markType = type
                        self.messages[row] = message
                        
                        // 2. Update Internal Dictionary
                        self.markedMessages[type]?.append(message)
                        
                        // 3. Sync to Database
                        self.syncToDatabase(type: type, text: message.text)
                        
                        // 4. Check Completion
                        self.generateStack.isHidden = false
                        
                        if self.isAllContentMarked() && !self.didShowFinalReadyMessage {
                            self.didShowFinalReadyMessage = true
                            
                            let finalMessage = Message(text: "less goo your post is ready", isUser: false)
                            self.messages.append(finalMessage)
                            
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                            self.tableView.insertRows(at: [indexPath], with: .fade)
                            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        }
                        
                        self.showScriptSuggestions()
                        self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                    }
                    alert.addAction(action)
                }
            }

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            // iPad Support
            if UIDevice.current.userInterfaceIdiom == .pad {
                if let popoverController = alert.popoverPresentationController {
                    popoverController.sourceView = cellView
                    popoverController.sourceRect = cellView.bounds
                    popoverController.permittedArrowDirections = .any
                }
            }
            
            self.present(alert, animated: true)
        }
    
    // MARK: - Smart Mock Generation (Hybrid)
//        func generateAndSaveMockData(for scriptText: String, ideaID: UUID) {
//            
//            Task {
//                // --- DEBUG START ---
//                let status = SystemLanguageModel.default.availability
//                print("🔍 Debugging Apple Intelligence Status: \(status)")
//                
//                // Detailed check (Optional, helps narrow it down)
//                if status != .available {
//                    print("⚠️ Reason: Likely models not downloaded in Settings or Region blocked.")
//                }
//                // --- DEBUG END ---
//
//                // STRATEGY 1: Try Apple Intelligence (If available)
//                if #available(iOS 18.0, *), status == .available {
//                    do {
//                        print("🧠 Attempting Apple Intelligence generation...")
//                        try await generateWithFoundationModel(scriptText: scriptText, ideaID: ideaID)
//                        return // Success! Exit function.
//                    } catch {
//                        print("⚠️ Apple Intelligence failed (\(error.localizedDescription)). Switching to fallback.")
//                    }
//                } else {
//                    print("ℹ️ Apple Intelligence unavailable. Skipping generation (Stays Untitled).")
//                }
//            }
//        }
    
    
    //MARK: GENERATING MOCK TITLE AND DESCRIPTION FUNCTION
    
    func generateAndSaveMockData(for scriptText: String, ideaID: UUID) {
            guard #available(iOS 18.0, *), AppleIntelligenceManager.shared.isAvailable else {
                print("ℹ️ Apple Intelligence unavailable. Skipping generation.")
                return
            }
            
            Task {
                let prompt = """
                Analyze this script. Return a Title and Description.
                Format:
                TITLE: [Title]
                DESC: [Description]
                
                Script:
                \(scriptText)
                """
                
                do {
                    print("🧠 Asking Apple Intelligence Manager...")
                    // --- CALLING THE NEW MANAGER ---
                    let result = try await AppleIntelligenceManager.shared.ask(prompt: prompt)
                    
                    //print(result)
                    
                    // Parse the result locally
                    try await parseAndSave(text: result, ideaID: ideaID, source: "Apple Intelligence")
                } catch {
                    print("⚠️ AI Manager Error: \(error.localizedDescription)")
                }
            }
        }
//    // MARK: - Helper 1: The AI Way (FoundationModels)
//        @available(iOS 18.0, *)
//        private func generateWithFoundationModel(scriptText: String, ideaID: UUID) async throws {
//            let prompt = """
//            Analyze this script. Return a Title and Description.
//            Format:
//            TITLE: [Title]
//            DESC: [Description]
//            
//            Script:
//            \(scriptText)
//            """
//            
//            let session = LanguageModelSession()
//            let response = try await session.respond(to: prompt)
//            let generatedText = response.content
//            
//            try await parseAndSave(text: generatedText, ideaID: ideaID, source: "Apple Intelligence")
//        }

        // MARK: - Shared Saver logic
        private func parseAndSave(text: String, ideaID: UUID, source: String) async throws {
            var newMockTitle: String?
            var newMockDesc: String?
            
            let lines = text.components(separatedBy: .newlines)
            for line in lines {
                
                let trimmed = line.replacingOccurrences(of: "*", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.uppercased().hasPrefix("TITLE:") {
                    newMockTitle = trimmed
                        .replacingOccurrences(of: "TITLE:", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .trimmingCharacters(in: CharacterSet(charactersIn: "\""))       // Remove quotes if AI added them
                } else if trimmed.uppercased().hasPrefix("DESC:") {
                    newMockDesc = trimmed
                        .replacingOccurrences(of: "DESC:", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        //.trimmingCharacters(in: CharacterSet(charactersIn: "\""))     // Remove quotes if AI added them
                }
            }
            
            if newMockTitle != nil || newMockDesc != nil {
                guard var script = self.currentActiveScript else { return }
                
                // Only overwrite if currently nil
                if script.mockTitle == nil { script.mockTitle = newMockTitle }
                if script.mockDescription == nil { script.mockDescription = newMockDesc }
                
                let updated = try await self.dbController.updateScript(script)
                
                await MainActor.run {
                    self.currentActiveScript = updated
                    print("✅ Mock data saved via \(source)")
                }
            } else {
                print("⚠️ Failed to parse Mock Data. AI Response format mismatch.")
            }
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
                        
                        // 2. Save all the chat history
                        print("💾 Saving chat history buffer...")
                        try await dbController.batchSaveMessages(ideaID: newScript.id, messages: self.messages)
                        print("✅ Chat history saved!")
                        
                        print("✨ Generating mock data with Apple Intelligence...")
                        self.generateAndSaveMockData(for: validText, ideaID: newScript.id)
                        
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
