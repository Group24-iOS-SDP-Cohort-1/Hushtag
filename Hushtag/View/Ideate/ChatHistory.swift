import UIKit

class ChatHistory: UITableViewController {

    let controller = ScriptedIdeasController()
    var chatMessages: [ChatMessageDB] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchHistory()
    }

    func fetchHistory() {
        Task {
            do {
                let history = try await controller.fetchChatHistory()

                await MainActor.run {
                    self.chatMessages = history
                    self.tableView.reloadData()
                }

            } catch {
                print("❌ Error fetching chat history:", error)
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ChatHistoryCell",
            for: indexPath
        ) as? ChatHistoryCell else {
            return UITableViewCell()
        }

        let msg = chatMessages[indexPath.row]

        cell.configure(with: msg)

        return cell
    }
}
