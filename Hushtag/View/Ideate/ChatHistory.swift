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
    
    @objc private func handleScriptDeleted(_ notification: Notification) {
        fetchConversationList()
    }
    
    func fetchConversationList() {
        Task {
            do {
                let result = try await controller.fetchConversations()
                
                let sorted = result.sorted {
                    ($0.created_at ?? Date()) > ($1.created_at ?? Date())
                }
                
                let grouped = groupConversations(sorted)
                
                
                await MainActor.run {
                    self.sections = grouped
                    self.tableView.reloadData()
                }
                
            } catch {
                print("❌ Failed to fetch conversations:", error)
            }
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let convo = sections[indexPath.section].items[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "Chatbot"
        ) as? Chatbot else { return }
        
        vc.conversationID = convo.id
        
        guard let navigationController = self.navigationController else { return }
        
        if let ideate1Index = navigationController.viewControllers.firstIndex(where: { String(describing: type(of: $0)) == "Ideate1" }) {
            let newStack = Array(navigationController.viewControllers[0...ideate1Index]) + [vc]
            navigationController.setViewControllers(newStack, animated: true)
        } else {
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
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
                    if let ideaId = convo.idea_id {
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
    }
    
    func groupConversations(_ conversations: [Conversation])
    -> [(title: String, items: [Conversation])] {
        
        let calendar = Calendar.current
        var grouped: [String: [Conversation]] = [:]
        
        for convo in conversations {
            guard let date = convo.created_at else { continue }
            
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
                ($0.1.first?.created_at ?? Date()) >
                ($1.1.first?.created_at ?? Date())
            }
    }
}
