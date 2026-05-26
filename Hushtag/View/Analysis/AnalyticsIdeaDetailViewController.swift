import UIKit

class AnalyticsIdeaDetailViewController: UIViewController {
    var analyticsIdea: AnalyticsIdea?
    var hasExistingScript: Bool = false
    var ideaMilestone: Int = 0
    var completedScriptTypes: Set<String> = []

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // Draft script progress view
    let progressContainer = UIView()
    let progressViewYourDraftBtn = UIButton(type: .system)
    var milestoneCheckmarks: [UIImageView] = []
    var milestoneDots: [UIView] = []
    var milestoneLabels: [UILabel] = []
    let trackView = UIView()
    let progressView = UIView()
    var progressWidthConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "AI Strategy"
        setupLayout()
        populateData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForExistingScript()
    }

    func checkForExistingScript() {
        guard let idea = analyticsIdea else { return }
        Task {
            do {
                let script = try await ScriptedIdeasController().fetchScriptByIdeaId(ideaId: idea.id)
                DispatchQueue.main.async {
                    self.hasExistingScript = script != nil
                    if let script = script {
                        var types: Set<String> = []
                        if let scriptText = script.script, !scriptText.isEmpty { types.insert("script") }
                        if let titleText = script.title, !titleText.isEmpty { types.insert("title") }
                        if let descText = script.description, !descText.isEmpty { types.insert("description") }
                        self.completedScriptTypes = types
                        self.ideaMilestone = types.count
                    } else {
                        self.completedScriptTypes = []
                        self.ideaMilestone = 0
                    }
                    self.updateProgressUI()
                }
            } catch {
                print("Failed to fetch script:", error)
            }
        }
    }
}
