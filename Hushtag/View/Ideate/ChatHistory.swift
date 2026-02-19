import UIKit

class ChatHistory: UITableViewController {

    let controller = ScriptedIdeasController()
    var conversations: [Conversation] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchConversationList()
    }

    func fetchConversationList() {
        Task {
            do {
                let result = try await controller.fetchConversations()

                await MainActor.run {
                    self.conversations = result
                    self.tableView.reloadData()
                }

            } catch {
                print("❌ Failed to fetch conversations:", error)
            }
        }
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ChatHistoryCell",
            for: indexPath
        ) as? ChatHistoryCell else {
            return UITableViewCell()
        }

        let msg = conversations[indexPath.row]

        cell.configure(with: msg)

        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {

        let convo = conversations[indexPath.row]

        let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)

        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "Chatbot"
        ) as? Chatbot else { return }

        vc.conversationID = convo.id   // ✅ Pass selected conversation

        navigationController?.pushViewController(vc, animated: true)
    }

}
