import UIKit

class ViewScriptsViewController: UIViewController {
    // var ideaResponse = IdeaResponse()
    var ideas: [Idea] = []
    private let likedIdeasController = LikedIdeasController()

    var pageTitle: String = ""
    var cellReuseIdentifier: String = "allScriptsCell"

    var isSearchMode = false
    var likedIdeas: [Idea] = []
    var myScripts: [ScriptedIdea] = []
    var chatHistory: [ChatMessageDB] = []

    let controller = ScriptedIdeasController()

    // Search related properties
    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    var filteredMyScripts: [ScriptedIdea] = []
    var filteredLikedIdeas: [Idea] = []

    @IBOutlet var scriptsCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchController()
        setupTapToDismiss()
        navigationItem.title = pageTitle
        scriptsCollectionView.dataSource = self
        scriptsCollectionView.delegate = self

        scriptsCollectionView.register(
            UINib(nibName: "ScriptsCell1", bundle: nil),
            forCellWithReuseIdentifier: "scriptedIdeas"
        )
        scriptsCollectionView.register(
            UINib(nibName: "LikedCellsNew", bundle: nil),
            forCellWithReuseIdentifier: "likedCellsNew"
        )

        let layout = generateScriptsLayout(title: pageTitle)
        scriptsCollectionView.setCollectionViewLayout(layout, animated: true)

        if pageTitle == "Chat History" || pageTitle == "Your Scripts" {
            fetchMyScripts()
        } else {
            syncLikedIdeas()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Refresh the list every time the view appears
        if pageTitle == "Your Scripts" || pageTitle == "Chat History" {
            fetchMyScripts()
        }
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        // searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "Search by title or tags"
        // searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    func setupTapToDismiss() {
        // Add gesture to the collection view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))

        // IMPORTANT: This allows taps to pass through to the cells if you tap a cell.
        // If you tap empty space, this gesture fires.
        // If you tap a cell, the didSelectItemAt delegate fires as well.
        tapGesture.cancelsTouchesInView = false

        scriptsCollectionView.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        // This closes the keyboard safely
        view.endEditing(true)

        // Optional: If you want to deactivate the search bar completely (like clicking Cancel)
        // searchController.isActive = false
    }

    func fetchMyScripts() {
        Task {
            do {
                // Fetch conversations to get sorted scripted ideas
                let conversations = try await controller.fetchConversations()

                // Extract scripts from conversations that have them
                let scripts = conversations.compactMap { conversation -> ScriptedIdea? in
                    guard let dbScript = conversation.scriptedIdeas else { return nil }
                    return ScriptedIdea(
                        id: dbScript.id,
                        chatId: dbScript.chatId,
                        title: dbScript.title,
                        description: dbScript.description,
                        script: dbScript.script,
                        thumbnail: dbScript.thumbnail,
                        tags: dbScript.tags,
                        ideaId: conversation.ideaId
                    )
                }

                await MainActor.run {
                    self.myScripts = scripts
                    self.filteredMyScripts = scripts

                    if self.isFiltering {
                        self.filterContentForSearchText(self.searchController.searchBar.text ?? "")
                    } else {
                        self.scriptsCollectionView.reloadData()
                        self.updateEmptyState()
                    }
                }
            } catch {
                print("Error fetching scripts: \(error)")
            }
        }
    }

    //    @objc func syncLikedIdeas() {
    //        likedIdeas = ideas.filter { LikedIds.likedIdeaIds.contains($0.id) }
    //        scriptsCollectionView.reloadData()
    //        updateEmptyState()
    //    }

    @objc func syncLikedIdeas() {
        Task {
            do {
                let ideas = try await likedIdeasController.fetchLikedIdeas()
                let personalizedIdeas = SessionManager.shared.personalizedIdeas

                let mergedIdeas = ideas.map { liked in
                    if let personalized = personalizedIdeas.first(where: { $0.ideaKey == liked.ideaKey }) {
                        var updated = personalized
                        updated.liked = true
                        return updated
                    }
                    return liked
                }

                await MainActor.run {
                    self.likedIdeas = mergedIdeas
                    self.filteredLikedIdeas = mergedIdeas
                    self.scriptsCollectionView.reloadData()
                    self.updateEmptyState()
                }
            } catch {
                print("Failed to fetch liked ideas:", error)
            }
        }
    }

    func updateEmptyState() {
        // Separate Empty State logic for "Your Scripts"
        if pageTitle == "Chat History" || pageTitle == "Your Scripts" {
            if myScripts.isEmpty {
                showEmptyView(message: "No scripts yet", iconName: "doc.text")
                scriptsCollectionView.backgroundView?.isHidden = false
            } else {
                scriptsCollectionView.backgroundView = nil
            }
            return
        }

        // Logic for "Liked Ideas"
        if likedIdeas.isEmpty {
            showEmptyView(message: "No liked ideas", iconName: "heart.slash")
            scriptsCollectionView.backgroundView?.isHidden = false
        } else {
            scriptsCollectionView.backgroundView = nil
        }
    }

    /// Helper to draw empty view
    func showEmptyView(message: String, iconName: String) {
        let emptyView = UIView(frame: scriptsCollectionView.bounds)

        let imageView = UIImageView(image: UIImage(systemName: iconName))
        imageView.tintColor = .tertiaryLabel
        imageView.heightAnchor.constraint(equalToConstant: 38).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 38).isActive = true

        let label = UILabel()
        label.text = message
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center

        emptyView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor)
        ])

        scriptsCollectionView.backgroundView = emptyView
    }
}
