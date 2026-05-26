import UIKit

class Chatbot: UIViewController, UITextViewDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var textView: UIView!
    @IBOutlet var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var textFieldView: UITextView!
    @IBOutlet var textStack: UIStackView!
    @IBOutlet var enterbutton: UIButton!
    @IBOutlet var generateStack: UIStackView!
    @IBOutlet var inputViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var scriptedChats: UIBarButtonItem!
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
        setupProgressHeader()
        loadConversationHistory()
        setupKeyboardObservers()
        setupTapToDismiss()
    }

    private func setupProgressHeader() {
        guard let header = Bundle.main.loadNibNamed("ProgressCell", owner: self, options: nil)?.first as? ProgressCell
        else { return }
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
            header.heightAnchor.constraint(equalToConstant: 125)
        ])
    }

    // MARK: - Conversation Loading

    private func loadConversationHistory() {
        Task {
            do {
                try await ensureConversationExists()
                let history = try await controller.fetchMessages(for: conversationID ?? UUID())
                let allIdeas = try await controller.fetchScript()
                let idea = allIdeas.first { $0.chatId == self.conversationID }
                let mapped = mapHistoryToMessages(history: history, idea: idea)
                await MainActor.run { self.applyLoadedHistory(mapped: mapped, idea: idea) }
            } catch {
                print("❌ Failed loading/creating conversation:", error)
            }
        }
    }

    private func ensureConversationExists() async throws {
        if conversationID == nil {
            let newConvoID = UUID()
            conversationID = newConvoID
            print("New Conversation started:", newConvoID)
            _ = try await controller.addConversation(id: newConvoID, ideaId: ideaId)
            print("Conversation created")
        } else {
            print("📌 Opening existing conversation:", conversationID!)
        }
    }

    private func mapHistoryToMessages(history: [ChatMessageDB], idea: ScriptedIdea?) -> [Message] {
        return history.map { chat -> Message in
            var message = Message(role: chat.role.rawValue, content: chat.content, mark: nil)
            guard let idea else { return message }
            if chat.content == idea.script { message.mark = "script"
            } else if chat.content == idea.title { message.mark = "title"
            } else if chat.content == idea.description { message.mark = "description" }
            return message
        }
    }

    private func applyLoadedHistory(mapped: [Message], idea: ScriptedIdea?) {
        if !mapped.isEmpty { self.messages = mapped }
        if let idea = idea {
            if let script = idea.script, !script.isEmpty {
                self.markedMessages["script"] = [Message(role: "bot", content: script, mark: "script")]
            }
            if let title = idea.title, !title.isEmpty {
                self.markedMessages["title"] = [Message(role: "bot", content: title, mark: "title")]
            }
            if let description = idea.description, !description.isEmpty {
                self.markedMessages["description"] = [Message(
                    role: "bot", content: description, mark: "description"
                )]
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

    private func navigateToViewIdea() {
        Task {
            do {
                let allIdeas = try await controller.fetchScript()
                guard let idea = allIdeas.first(where: { $0.chatId == self.conversationID }) else {
                    print("No scripted idea found for this conversation")
                    return
                }
                await MainActor.run {
                    let storyboard = UIStoryboard(name: "Ideate", bundle: nil)
                    guard let scriptedIdeasVC = storyboard
                        .instantiateViewController(withIdentifier: "scriptedIdea") as? ScriptedIdeas else { return }
                    scriptedIdeasVC.idea = idea
                    self.navigationController?.pushViewController(scriptedIdeasVC, animated: true)
                }
            } catch {
                print("Failed to fetch scripted idea:", error)
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - State Helpers

    func isTypeAlreadyMarked(_ type: String) -> Bool {
        return !(markedMessages[type]?.isEmpty ?? true)
    }

    func isAllContentMarked() -> Bool {
        for type in requiredMarkTypes where markedMessages[type]?.isEmpty ?? true {
            return false
        }
        return true
    }

    func getUnmarkedTypes() -> [String] {
        return requiredMarkTypes.filter { type in
            markedMessages[type]?.isEmpty ?? true
        }
    }

    func buildCleanHistory() -> [Message] {
        return messages.filter {
            $0.content != "Thinking..." &&
                $0.role != "system"
        }
    }

    func updateProgressHeader() {
        let completedTypes = Set(requiredMarkTypes.filter {
            !(markedMessages[$0]?.isEmpty ?? true)
        })
        progressHeader?.configure(completedTypes: completedTypes)
    }

    // MARK: - Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if messages.isEmpty {
            let welcomeMessage = "Welcome! I'm your scripting assistant. Lets write a script for you."
            messages.append(Message(role: "system", content: welcomeMessage))
            tableView.reloadData()
            scrollToBottom()
        }
    }

    // MARK: - IBActions

    @IBAction func scriptView(_: Any) {
        let storyboard = UIStoryboard(name: "ChatHistory", bundle: nil)
        guard let navVC = storyboard.instantiateInitialViewController() as? UINavigationController else { return }
        guard let destinationVC = navVC.topViewController as? ChatHistory else { return }
        navigationController?.pushViewController(destinationVC, animated: true)
    }

    @IBAction func sendButton(_: Any) {
        let text = textFieldView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty {
            sendMessage(text)
        }
    }

    @objc func generateButtonTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        sendMessage(title)
        generateStack.isHidden = true
    }

    // MARK: - Keyboard

    func setupTapToDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tableView.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
            .cgRectValue {
            let bottomPadding = view.safeAreaInsets.bottom
            inputViewBottomConstraint.constant = keyboardSize.height - bottomPadding
            UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
            scrollToBottom()
        }
    }

    @objc func keyboardWillHide(notification _: NSNotification) {
        inputViewBottomConstraint.constant = 8
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }

    func scrollToBottom() {
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}
