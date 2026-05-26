import UIKit

// MARK: - UITableViewDelegate & UITableViewDataSource

extension Chatbot: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return messages.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return makePlatformCell(tableView: tableView, indexPath: indexPath)
        }
        return makeChatCell(tableView: tableView, indexPath: indexPath)
    }

    private func makePlatformCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: "PlatformCell", for: indexPath) as? PlatformCellTableViewCell
        else { return UITableViewCell() }

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

    private func makeChatCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let messageIndex = indexPath.row - 1
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ChatCell", for: indexPath
        ) as? ChatCell else { return UITableViewCell() }

        cell.configure(with: messages[messageIndex])
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        cell.contentView.addGestureRecognizer(longPress)
        cell.contentView.tag = messageIndex
        return cell
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}

// MARK: - Text Input

extension Chatbot {
    func textViewDidChange(_ textView: UITextView) {
        guard textView.font != nil else { return }

        let lineHeight = textView.font?.lineHeight ?? 0
        let inset = textView.textContainerInset.top + textView.textContainerInset.bottom
        let maxHeight = (lineHeight * 10) + inset
        let minHeight = (lineHeight * 3) + inset

        let size = CGSize(width: textView.frame.width, height: .infinity)
        let contentHeight = textView.sizeThatFits(size).height

        if contentHeight >= maxHeight {
            textViewHeightConstraint.constant = maxHeight
            textView.isScrollEnabled = true
        } else if contentHeight < maxHeight, contentHeight > minHeight {
            textViewHeightConstraint.constant = contentHeight
            textView.isScrollEnabled = false
        } else if contentHeight <= minHeight {
            textViewHeightConstraint.constant = minHeight
            textView.isScrollEnabled = false
        }

        UIView.animate(withDuration: 0.1) { self.view.layoutIfNeeded() }
    }
}

// MARK: - Send Message

extension Chatbot {
    func sendMessage(_ text: String) {
        let userText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userText.isEmpty else { return }
        guard let conversationID = conversationID else { return }

        // 1. Show + save user message
        messages.append(Message(role: "user", content: userText))
        tableView.reloadData()
        scrollToBottom()
        textFieldView.text = ""
        textViewDidChange(textFieldView)
        saveUserMessage(userText, conversationID: conversationID)

        // 2. Show loading
        messages.append(Message(role: "bot", content: "Thinking..."))
        tableView.reloadData()
        scrollToBottom()

        // 3. AI processing
        Task { [weak self] in
            guard let self = self else { return }
            await self.dispatchToAI(userText: userText, conversationID: conversationID)
        }
    }

    private func saveUserMessage(_ userText: String, conversationID: UUID) {
        Task {
            do {
                _ = try await self.controller.addChatMessage(
                    id: conversationID,
                    sender: .user,
                    content: userText
                )
            } catch {
                print("❌ Failed to save user message:", error)
            }
        }
    }

    private func buildFinalPrompt(userText: String) -> String {
        let platform = self.selectedPlatform ?? "general"
        let historyText = self.buildCleanHistory()
            .suffix(10)
            .map { "\($0.role): \($0.content)" }
            .joined(separator: "\n")
        return """
        You are a content assistant for \(platform).

        Conversation so far:
        \(historyText)

        User:
        \(userText)
        """
    }

    private func dispatchToAI(userText: String, conversationID: UUID) async {
        let intent = await AIResponseRouter.shared.classifyIntent(
            message: userText,
            conversationID: conversationID,
            platform: selectedPlatform
        )
        let finalPrompt = buildFinalPrompt(userText: userText)

        switch intent {
        case .generateScript:
            GeminiManager.shared.generateContent(
                prompt: finalPrompt,
                conversationID: conversationID
            ) { reply in
                self.latestScript = reply
                self.handleBotReply(reply, source: "gemini")
            }

        case .generateTitle:
            let reply = await generateTitleWithApple(
                script: self.latestScript,
                userPrompt: finalPrompt,
                conversationID: conversationID
            )
            self.handleBotReply(reply, source: "apple")

        case .generateDescription:
            let reply = await generateDescriptionWithApple(
                script: self.latestScript,
                userPrompt: finalPrompt,
                conversationID: conversationID
            )
            self.handleBotReply(reply, source: "apple")

        case .chat:
            let reply = await AIResponseRouter.shared.respond(
                intent: .chat,
                prompt: finalPrompt,
                conversationID: conversationID
            )
            self.handleBotReply(reply, source: "router")
        }
    }

    func handleBotReply(_ replyText: String?, source _: String) {
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

        DispatchQueue.main.async {
            if !self.messages.isEmpty { self.messages.removeLast() }

            guard let replyText else {
                self.messages.append(Message(role: "bot", content: "Something went wrong."))
                self.tableView.reloadData()
                self.scrollToBottom()
                return
            }

            self.messages.append(Message(role: "bot", content: replyText))
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }
}

// MARK: - Long Press / Mark Actions

extension Chatbot {
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let cellView = gesture.view else { return }

        let row = cellView.tag
        let message = messages[row]
        guard message.role != "user" else { return }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        ["script", "title", "description"].forEach { type in
            let isMarked = message.mark == type
            if !isMarked && isTypeAlreadyMarked(type) { return }

            let title = isMarked ? "Unmark \(type.capitalized)" : "Mark as \(type.capitalized)"
            alert.addAction(UIAlertAction(title: title, style: .default) { _ in
                var localMessage = self.messages[row]
                if isMarked {
                    self.performUnmark(type: type, message: &localMessage)
                } else {
                    self.performMark(type: type, message: &localMessage)
                }
                self.messages[row] = localMessage
                self.tableView.reloadRows(at: [IndexPath(row: row + 1, section: 0)], with: .none)
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func performUnmark(type: String, message: inout Message) {
        message.mark = nil
        self.markedMessages[type]?.removeAll { $0.content == message.content }
        self.updateProgressHeader()
        guard let chatID = self.conversationID else { return }
        Task {
            do {
                try await self.controller.upsertScriptField(chatID: chatID, field: type, value: "")
                print("🗑️ Removed \(type) from scripted_ideas")
            } catch {
                print("❌ Failed to remove \(type):", error)
            }
        }
    }

    private func performMark(type: String, message: inout Message) {
        if let oldType = message.mark {
            self.markedMessages[oldType]?.removeAll { $0.content == message.content }
        }
        self.generateStack.isHidden = false
        message.mark = type
        self.markedMessages[type]?.append(message)
        self.updateProgressHeader()

        let content = message.content
        if let chatID = self.conversationID {
            Task {
                do {
                    try await self.controller.upsertScriptField(
                        chatID: chatID, field: type, value: content
                    )
                    print(" Saved \(type) to scripted_ideas")
                } catch {
                    print(" Failed to save \(type):", error)
                }
            }
        }

        if self.isAllContentMarked() && !self.didShowFinalReadyMessage {
            self.showPostReadyAlert()
        }

        self.showScriptSuggestions()
    }

    private func showPostReadyAlert() {
        didShowFinalReadyMessage = true
        let finalMessage = Message(role: "bot", content: "less goo your post is ready")
        self.messages.append(finalMessage)
        let indexPath = IndexPath(row: self.messages.count, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .fade)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)

        let postAlert = UIAlertController(
            title: "Post Ready",
            message: "Your post is ready! What would you like to do?",
            preferredStyle: .alert
        )
        postAlert.addAction(UIAlertAction(title: "Continue drafting", style: .cancel))
        postAlert.addAction(UIAlertAction(title: "View post", style: .default) { _ in
            guard let navigationController = self.navigationController else { return }
            if let ideate1 = navigationController.viewControllers.first(where: { $0 is Ideate1 }) {
                navigationController.popToViewController(ideate1, animated: true)
            } else {
                navigationController.popViewController(animated: true)
            }
        })
        self.present(postAlert, animated: true)
    }
}

// MARK: - Suggestion Buttons

extension Chatbot {
    func showScriptSuggestions() {
        generateStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let unmarkedTypes = getUnmarkedTypes()
        if unmarkedTypes.isEmpty {
            generateStack.isHidden = true
            return
        }

        generateStack.isHidden = false

        for type in unmarkedTypes {
            let buttonTitle: String
            switch type {
            case "script":      buttonTitle = "Generate Script"
            case "title":       buttonTitle = "Generate Title"
            case "description": buttonTitle = "Generate Description"
            default: continue
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
}
