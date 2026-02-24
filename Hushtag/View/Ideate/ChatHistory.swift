import UIKit

class ChatHistory: UITableViewController {
    
    let controller = ScriptedIdeasController()
    var conversations: [Conversation] = []
    var sections: [(title: String, items: [Conversation])] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        
        let convo = sections[indexPath.section].items[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "Chatbot"
        ) as? Chatbot else { return }
        
        vc.conversationID = convo.id
        
        navigationController?.pushViewController(vc, animated: true)
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
