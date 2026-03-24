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
                    self.updateEmptyState()
                }
            } catch {
                print("Error loading scripts for existing post: \(error)")
            }
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func updateEmptyState() {
        if scripts.isEmpty {
            showEmptyView(message: "No existing post", iconName: "doc.text.magnifyingglass")
        } else {
            tableView.backgroundView = nil
        }
    }
    
    private func showEmptyView(message: String, iconName: String) {
        let emptyView = UIView(frame: tableView.bounds)
        
        let imageView = UIImageView(image: UIImage(systemName: iconName))
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = message
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        emptyView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -40),
            imageView.heightAnchor.constraint(equalToConstant: 44),
            imageView.widthAnchor.constraint(equalToConstant: 44)
        ])
        
        tableView.backgroundView = emptyView
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
        let script = scripts[indexPath.row]
        
        let storyboard = UIStoryboard(name: "CreatePost", bundle: nil)
        if let nav = storyboard.instantiateViewController(withIdentifier: "NavCreatePost") as? UINavigationController,
           let createVC = nav.topViewController as? CreatePostViewController {
            
            createVC.prefill(title: script.title, description: script.description)
            
            // Dismiss current selector then present create post
            self.dismiss(animated: true) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.present(nav, animated: true)
                }
            }
        }
    }
}
