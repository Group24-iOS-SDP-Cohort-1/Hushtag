import UIKit

extension ScriptedIdeas {
    @objc func handleDealTagChanged() {
        fetchDealsData()
    }

    @objc func handleScriptDeletedRemotely(_ notification: Notification) {
        guard let deletedID = notification.userInfo?["deletedID"] as? UUID,
              deletedID == idea?.id else { return }

        // This instance is showing the deleted idea — navigate away
        if navigationController?.presentingViewController != nil {
            navigationController?.dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    func fetchDealsData() {
        guard let ideaId = idea?.id else { return }

        Task {
            do {
                let fetchedDeals = try await DealsController().fetchDeals()
                let mappings = try await BrandDealIdeasController().fetchDealsForScript(scriptedIdeaId: ideaId)

                DispatchQueue.main.async {
                    self.allDeals = fetchedDeals
                    let ids = mappings.map { $0.dealId }
                    self.taggedDealIds = Set(ids)
                    self.orderedTaggedDealIds = ids
                    self.ideaView.reloadData() // Reload to update button menu if needed
                }
            } catch {
                print("Failed to fetch deals data: \(error)")
            }
        }
    }

    @objc func buttonTapped(_ sender: UIButton) {
        let section = sections[sender.tag]

        switch section {
        case .description:
            isDescriptionExpanded.toggle()

        case .script:
            isScriptExpanded.toggle()

        default:
            return
        }

        ideaView.reloadSections(IndexSet(integer: sender.tag))
    }

    func setupMenu() {
        if isEditingMode {
            let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveEdits))
            navigationItem.rightBarButtonItem = saveButton
            return
        }

        let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [weak self] _ in
            self?.toggleEditMode()
        }
        let deleteAction = UIAction(
            title: "Delete Script",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.confirmDelete()
        }

        let menuChildren = isModal ? [deleteAction] : [editAction, deleteAction]

        let menu = UIMenu(title: "", children: menuChildren)

        if navigationItem.rightBarButtonItem != optionsBarButton {
            navigationItem.rightBarButtonItem = optionsBarButton
        }
        optionsBarButton.menu = menu
    }

    @objc func toggleEditMode() {
        isEditingMode = true
        setupMenu()
        isDescriptionExpanded = true
        isScriptExpanded = true
        ideaView.reloadData()
    }

    @objc func saveEdits() {
        guard let id = idea?.id else { return }

        isEditingMode = false
        setupMenu()
        ideaView.reloadData()

        Task {
            do {
                try await ScriptedIdeasController().updateScript(
                    id: id,
                    title: idea?.title,
                    description: idea?.description,
                    script: idea?.script
                )
            } catch {
                print("Error saving edits: \(error)")
            }
        }
    }

    @IBAction func draftClick(_: Any) {
        navigateToChat()
    }

    func confirmDelete() {
        let alert = UIAlertController(
            title: "Delete Script",
            message: "Are you sure? This cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.performDelete()
        }))

        present(alert, animated: true)
    }

    func performDelete() {
        guard let id = idea?.id else { return }

        Task {
            do {
                try await ScriptedIdeasController().deleteScript(id: id)

                NotificationCenter.default.post(
                    name: .scriptDeleted,
                    object: nil,
                    userInfo: ["deletedID": id]
                )

                DispatchQueue.main.async {
                    if self.navigationController?.presentingViewController != nil {
                        self.navigationController?.dismiss(animated: true)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }

            } catch {
                print("Error deleting script: \(error)")
            }
        }
    }

    func navigateToChat() {
        guard let idea = idea else { return }

        let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)

        guard let chatVC = storyboard.instantiateViewController(
            withIdentifier: "Chatbot"
        ) as? Chatbot else { return }

        // This is the important line
        chatVC.conversationID = idea.chatId

        navigationController?.pushViewController(chatVC, animated: true)
    }

    @IBAction func schedule(_: Any) {
        let storyboard = UIStoryboard(name: "AddPostViewController", bundle: nil)
        let modalVC = storyboard.instantiateViewController(withIdentifier: "AddPostNavVC")
        modalVC.modalPresentationStyle = .pageSheet
        modalVC.modalTransitionStyle = .coverVertical
        present(modalVC, animated: true)
    }
}
