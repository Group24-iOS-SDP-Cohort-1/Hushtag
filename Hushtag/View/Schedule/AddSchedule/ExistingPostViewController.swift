import UIKit

class ExistingPostViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let scriptsController = ScriptedIdeasController()
    private var scripts: [ScriptedIdea] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupTableView()
        loadScripts()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func loadScripts() {
        Task {
            do {
                let conversations = try await scriptsController.fetchConversations()
                let fetchedScripts = conversations.compactMap { conversation -> ScriptedIdea? in
                    guard let dbScript = conversation.scripted_ideas else { return nil }
                    return ScriptedIdea(
                        id: dbScript.id,
                        chat_id: dbScript.chat_id,
                        title: dbScript.title,
                        description: dbScript.description,
                        script: dbScript.script,
                        thumbnail: dbScript.thumbnail,
                        tags: dbScript.tags
                    )
                }
                
                await MainActor.run {
                    self.scripts = fetchedScripts
                    self.tableView.reloadData()
                }
            } catch {
                print("Error loading scripts for existing post: \(error)")
            }
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension ExistingPostViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scripts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExistingPostCell", for: indexPath)
        let script = scripts[indexPath.row]
        
        cell.textLabel?.text = script.title ?? "Untitled Script"
        cell.textLabel?.font = .preferredFont(forTextStyle: .body)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // For now, just dismiss the modal when a script is selected
        dismiss(animated: true)
    }
}
