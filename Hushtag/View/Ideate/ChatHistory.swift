import UIKit

class ChatHistory: UITableViewController {
    let controller = ScriptedIdeasController()
    var conversations: [Conversation] = []
    var sections: [(title: String, items: [Conversation])] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScriptDeleted),
            name: .scriptDeleted,
            object: nil
        )
        fetchConversationList()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchConversationList()
    }

    @objc private func handleScriptDeleted(_: Notification) {
        fetchConversationList()
    }

    func fetchConversationList() {
        Task {
            do {
                let result = try await controller.fetchConversations()

                let sorted = result.sorted {
                    ($0.createdAt ?? Date()) > ($1.createdAt ?? Date())
                }

                let grouped = groupConversations(sorted)

                await MainActor.run {
                    self.sections = grouped
                    self.tableView.reloadData()
                    self.updateEmptyState()
                }

            } catch {
                print("❌ Failed to fetch conversations:", error)
                await MainActor.run {
                    self.updateEmptyState()
                }
            }
        }
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return sections.count
    }

    override func tableView(
        _: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ChatHistoryCell",
            for: indexPath
        ) as? ChatHistoryCell else {
            return UITableViewCell()
        }

        let convo = sections[indexPath.section].items[indexPath.row]
        cell.configure(with: convo)

        return cell
    }

    override func tableView(
        _: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        return sections[section].title
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let convo = sections[indexPath.section].items[indexPath.row]

        let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)

        guard let viewController = storyboard.instantiateViewController(
            withIdentifier: "Chatbot"
        ) as? Chatbot else { return }

        viewController.conversationID = convo.id

        guard let navigationController = navigationController else { return }

        if let ideate1Index = navigationController.viewControllers.firstIndex(where: { $0 is Ideate1 }) {
            let newStack = Array(navigationController.viewControllers[0 ... ideate1Index]) + [viewController]
            navigationController.setViewControllers(newStack, animated: true)
        } else {
            navigationController.pushViewController(viewController, animated: true)
        }
    }

    override func tableView(
        _: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    )
        -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { [weak self] _, _, completion in
            guard let self = self else { return }

            let convo = self.sections[indexPath.section].items[indexPath.row]

            Task {
                do {
                    // Delete related script first if it exists
                    if let ideaId = convo.ideaId {
                        try await self.controller.deleteScript(id: ideaId)
                    }

                    // Delete conversation
                    try await self.controller.deleteConversation(id: convo.id)

                    // Update UI
                    await MainActor.run {
                        self.removeConversationFromDataSource(at: indexPath)
                        completion(true)
                    }

                } catch {
                    print("❌ Failed to delete:", error)
                    completion(false)
                }
            }
        }

        deleteAction.image = UIImage(systemName: "trash")

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    private func removeConversationFromDataSource(at indexPath: IndexPath) {
        sections[indexPath.section].items.remove(at: indexPath.row)

        if sections[indexPath.section].items.isEmpty {
            sections.remove(at: indexPath.section)
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
        } else {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }

        updateEmptyState()
    }

    private func updateEmptyState() {
        if sections.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "There is no chat history currently."
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.textAlignment = .center
            emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            emptyLabel.numberOfLines = 0

            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
    }

    func groupConversations(_ conversations: [Conversation])
        -> [(title: String, items: [Conversation])] {
        let calendar = Calendar.current
        var grouped: [String: [Conversation]] = [:]

        for convo in conversations {
            guard let date = convo.createdAt else { continue }

            let title: String

            if calendar.isDateInToday(date) {
                title = "Today"
            } else if calendar.isDateInYesterday(date) {
                title = "Yesterday"
            } else {
                let daysAgo = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0

                if daysAgo < 7 {
                    title = date.dayOnly()
                } else {
                    title = date.dateAndMonth()
                }
            }

            grouped[title, default: []].append(convo)
        }

        return grouped
            .map { ($0.key, $0.value) }
            .sorted {
                ($0.1.first?.createdAt ?? Date()) >
                    ($1.1.first?.createdAt ?? Date())
            }
    }
}
