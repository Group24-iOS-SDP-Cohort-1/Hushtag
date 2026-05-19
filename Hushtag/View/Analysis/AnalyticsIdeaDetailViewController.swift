import Foundation
import UIKit

class AnalyticsIdeaDetailViewController: UIViewController {
    var analyticsIdea: AnalyticsIdea?
    var hasExistingScript: Bool = false
    var ideaMilestone: Int = 0
    var completedScriptTypes: Set<String> = []

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 24
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // Draft script progress view (we will build this below)
    private let progressContainer = UIView()
    private let progressViewYourDraftBtn = UIButton(type: .system)
    private var milestoneCheckmarks: [UIImageView] = []
    private var milestoneDots: [UIView] = []
    private var milestoneLabels: [UILabel] = []
    private let trackView = UIView()
    private let progressView = UIView()
    private var progressWidthConstraint: NSLayoutConstraint?

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

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }

    private func populateData() {
        guard let idea = analyticsIdea else { return }

        // 1. Hero Section
        let heroCard = createCardView()

        let titleLabel = UILabel()
        titleLabel.text = idea.title
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let metaLabel = UILabel()
        metaLabel.text = "\(idea.format.uppercased()) • Virality: \(Int(idea.estimatedViralityScore))"
        metaLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        metaLabel.textColor = .accent
        metaLabel.translatesAutoresizingMaskIntoConstraints = false

        heroCard.addSubview(titleLabel)
        heroCard.addSubview(metaLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -20),

            metaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            metaLabel.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 20),
            metaLabel.bottomAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: -20)
        ])
        stackView.addArrangedSubview(heroCard)

        // 2. Draft Progress
        setupDraftProgressView()

        // 3. AI Strategy Card
        let strategyCard = createCardView()
        let strategyTitle = createSectionTitle("Why it will work")
        let strategyLabel = UILabel()
        strategyLabel.text = idea.whyItWillWork.joined(separator: "\n• ")
        strategyLabel.text = "• " + (strategyLabel.text ?? "")
        strategyLabel.numberOfLines = 0
        strategyLabel.font = .systemFont(ofSize: 15, weight: .regular)
        strategyLabel.textColor = .secondaryLabel
        strategyLabel.translatesAutoresizingMaskIntoConstraints = false

        let emotionLabel = UILabel()
        emotionLabel.text = "Target Emotion: \(idea.targetEmotion)"
        emotionLabel.font = .systemFont(ofSize: 14, weight: .medium)
        emotionLabel.translatesAutoresizingMaskIntoConstraints = false

        strategyCard.addSubview(strategyTitle)
        strategyCard.addSubview(emotionLabel)
        strategyCard.addSubview(strategyLabel)

        NSLayoutConstraint.activate([
            strategyTitle.topAnchor.constraint(equalTo: strategyCard.topAnchor, constant: 20),
            strategyTitle.leadingAnchor.constraint(equalTo: strategyCard.leadingAnchor, constant: 20),

            emotionLabel.topAnchor.constraint(equalTo: strategyTitle.bottomAnchor, constant: 12),
            emotionLabel.leadingAnchor.constraint(equalTo: strategyCard.leadingAnchor, constant: 20),

            strategyLabel.topAnchor.constraint(equalTo: emotionLabel.bottomAnchor, constant: 12),
            strategyLabel.leadingAnchor.constraint(equalTo: strategyCard.leadingAnchor, constant: 20),
            strategyLabel.trailingAnchor.constraint(equalTo: strategyCard.trailingAnchor, constant: -20),
            strategyLabel.bottomAnchor.constraint(equalTo: strategyCard.bottomAnchor, constant: -20)
        ])
        stackView.addArrangedSubview(strategyCard)

        // 4. Hook & Timeline
        let hookCard = createCardView()
        let hookTitle = createSectionTitle("Opening Flow")

        let hookLabel = UILabel()
        hookLabel.text = "Hook: \(idea.hook)"
        hookLabel.numberOfLines = 0
        hookLabel.font = .systemFont(ofSize: 15, weight: .bold)
        hookLabel.translatesAutoresizingMaskIntoConstraints = false

        let openingLabel = UILabel()
        openingLabel.text = idea.opening30Seconds.joined(separator: "\n")
        openingLabel.numberOfLines = 0
        openingLabel.font = .systemFont(ofSize: 15, weight: .regular)
        openingLabel.textColor = .secondaryLabel
        openingLabel.translatesAutoresizingMaskIntoConstraints = false

        hookCard.addSubview(hookTitle)
        hookCard.addSubview(hookLabel)
        hookCard.addSubview(openingLabel)

        NSLayoutConstraint.activate([
            hookTitle.topAnchor.constraint(equalTo: hookCard.topAnchor, constant: 20),
            hookTitle.leadingAnchor.constraint(equalTo: hookCard.leadingAnchor, constant: 20),

            hookLabel.topAnchor.constraint(equalTo: hookTitle.bottomAnchor, constant: 12),
            hookLabel.leadingAnchor.constraint(equalTo: hookCard.leadingAnchor, constant: 20),
            hookLabel.trailingAnchor.constraint(equalTo: hookCard.trailingAnchor, constant: -20),

            openingLabel.topAnchor.constraint(equalTo: hookLabel.bottomAnchor, constant: 12),
            openingLabel.leadingAnchor.constraint(equalTo: hookCard.leadingAnchor, constant: 20),
            openingLabel.trailingAnchor.constraint(equalTo: hookCard.trailingAnchor, constant: -20),
            openingLabel.bottomAnchor.constraint(equalTo: hookCard.bottomAnchor, constant: -20)
        ])
        stackView.addArrangedSubview(hookCard)

        // 5. Thumbnail
        if let thumb = idea.thumbnailConcept {
            let thumbCard = createCardView()
            let thumbTitle = createSectionTitle("Thumbnail Concept")

            let vStack = UIStackView()
            vStack.axis = .vertical
            vStack.spacing = 8
            vStack.translatesAutoresizingMaskIntoConstraints = false

            let txtLabel = UILabel()
            txtLabel.text = "Text: \(thumb.text)"
            txtLabel.numberOfLines = 0
            txtLabel.font = .systemFont(ofSize: 15)

            let visLabel = UILabel()
            visLabel.text = "Visual: \(thumb.visual)"
            visLabel.numberOfLines = 0
            visLabel.font = .systemFont(ofSize: 15)

            vStack.addArrangedSubview(txtLabel)
            vStack.addArrangedSubview(visLabel)

            thumbCard.addSubview(thumbTitle)
            thumbCard.addSubview(vStack)
            NSLayoutConstraint.activate([
                thumbTitle.topAnchor.constraint(equalTo: thumbCard.topAnchor, constant: 20),
                thumbTitle.leadingAnchor.constraint(equalTo: thumbCard.leadingAnchor, constant: 20),

                vStack.topAnchor.constraint(equalTo: thumbTitle.bottomAnchor, constant: 12),
                vStack.leadingAnchor.constraint(equalTo: thumbCard.leadingAnchor, constant: 20),
                vStack.trailingAnchor.constraint(equalTo: thumbCard.trailingAnchor, constant: -20),
                vStack.bottomAnchor.constraint(equalTo: thumbCard.bottomAnchor, constant: -20)
            ])
            stackView.addArrangedSubview(thumbCard)
        }

        // 6. Metrics Grid
        let metricsTitle = createSectionTitle("Performance Estimations")
        stackView.addArrangedSubview(metricsTitle)

        let gridStack = UIStackView()
        gridStack.axis = .horizontal
        gridStack.distribution = .fillEqually
        gridStack.spacing = 16

        let leftCol = UIStackView()
        leftCol.axis = .vertical
        leftCol.spacing = 16

        let rightCol = UIStackView()
        rightCol.axis = .vertical
        rightCol.spacing = 16

        leftCol.addArrangedSubview(createMetricCard(title: "CTR", value: "\(Int(idea.estimatedCTR * 100))%"))
        leftCol.addArrangedSubview(createMetricCard(title: "Virality", value: "\(Int(idea.estimatedViralityScore))/100"))

        rightCol.addArrangedSubview(createMetricCard(title: "Retention", value: "\(Int(idea.estimatedRetention * 100))%"))
        rightCol.addArrangedSubview(createMetricCard(title: "Difficulty", value: idea.difficulty.capitalized))

        gridStack.addArrangedSubview(leftCol)
        gridStack.addArrangedSubview(rightCol)
        stackView.addArrangedSubview(gridStack)
    }

    private func createCardView() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.5)
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.systemGray5.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    private func createSectionTitle(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 18, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func createMetricCard(title: String, value: String) -> UIView {
        let card = createCardView()

        let vLabel = UILabel()
        vLabel.text = value
        vLabel.font = .systemFont(ofSize: 24, weight: .bold)
        vLabel.textColor = .accent
        vLabel.adjustsFontSizeToFitWidth = true
        vLabel.minimumScaleFactor = 0.5
        vLabel.numberOfLines = 1
        vLabel.translatesAutoresizingMaskIntoConstraints = false

        let tLabel = UILabel()
        tLabel.text = title
        tLabel.font = .systemFont(ofSize: 13, weight: .medium)
        tLabel.textColor = .secondaryLabel
        tLabel.adjustsFontSizeToFitWidth = true
        tLabel.minimumScaleFactor = 0.5
        tLabel.numberOfLines = 1
        tLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(vLabel)
        card.addSubview(tLabel)

        NSLayoutConstraint.activate([
            vLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            vLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),

            tLabel.topAnchor.constraint(equalTo: vLabel.bottomAnchor, constant: 4),
            tLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            tLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }

    // MARK: - Draft Script Logic

    private func setupDraftProgressView() {
        progressContainer.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.5)
        progressContainer.layer.cornerRadius = 16
        progressContainer.layer.borderWidth = 1
        progressContainer.layer.borderColor = UIColor.systemGray5.cgColor
        progressContainer.translatesAutoresizingMaskIntoConstraints = false

        let headerLabel = UILabel()
        headerLabel.text = "Script Progress"
        headerLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        progressContainer.addSubview(headerLabel)

        progressViewYourDraftBtn.setTitle("Draft Script", for: .normal)
        progressViewYourDraftBtn.backgroundColor = UIColor.accent.withAlphaComponent(0.15)
        progressViewYourDraftBtn.setTitleColor(.accent, for: .normal)
        progressViewYourDraftBtn.layer.cornerRadius = 16
        progressViewYourDraftBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        progressViewYourDraftBtn.translatesAutoresizingMaskIntoConstraints = false
        progressViewYourDraftBtn.addTarget(self, action: #selector(didTapDraftScript), for: .touchUpInside)
        progressContainer.addSubview(progressViewYourDraftBtn)

        let pBar = UIView()
        pBar.translatesAutoresizingMaskIntoConstraints = false
        progressContainer.addSubview(pBar)

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: progressContainer.topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor, constant: 16),

            pBar.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16),
            pBar.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor, constant: 16),
            pBar.trailingAnchor.constraint(equalTo: progressContainer.trailingAnchor, constant: -16),
            pBar.heightAnchor.constraint(equalToConstant: 40),

            progressViewYourDraftBtn.topAnchor.constraint(equalTo: pBar.bottomAnchor, constant: 16),
            progressViewYourDraftBtn.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor, constant: 16),
            progressViewYourDraftBtn.trailingAnchor.constraint(equalTo: progressContainer.trailingAnchor, constant: -16),
            progressViewYourDraftBtn.bottomAnchor.constraint(equalTo: progressContainer.bottomAnchor, constant: -16),
            progressViewYourDraftBtn.heightAnchor.constraint(equalToConstant: 44)
        ])

        // Inner track
        trackView.backgroundColor = UIColor.systemGray4
        trackView.translatesAutoresizingMaskIntoConstraints = false
        pBar.addSubview(trackView)

        progressView.backgroundColor = .accent
        progressView.translatesAutoresizingMaskIntoConstraints = false
        trackView.addSubview(progressView)

        NSLayoutConstraint.activate([
            trackView.centerYAnchor.constraint(equalTo: pBar.centerYAnchor, constant: -10),
            trackView.leadingAnchor.constraint(equalTo: pBar.leadingAnchor, constant: 16),
            trackView.trailingAnchor.constraint(equalTo: pBar.trailingAnchor, constant: -16),
            trackView.heightAnchor.constraint(equalToConstant: 4),

            progressView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            progressView.topAnchor.constraint(equalTo: trackView.topAnchor),
            progressView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor)
        ])

        progressWidthConstraint = progressView.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: 0.001)
        progressWidthConstraint?.isActive = true

        let milestones = ["Script", "Title", "Description"]
        for (i, m) in milestones.enumerated() {
            let dot = UIView()
            dot.backgroundColor = .systemGray5
            dot.layer.cornerRadius = 10
            dot.layer.borderWidth = 2
            dot.layer.borderColor = UIColor.systemGray3.cgColor
            dot.translatesAutoresizingMaskIntoConstraints = false
            pBar.addSubview(dot)
            milestoneDots.append(dot)

            let lbl = UILabel()
            lbl.text = m
            lbl.font = .systemFont(ofSize: 11, weight: .medium)
            lbl.textColor = .systemGray
            lbl.translatesAutoresizingMaskIntoConstraints = false
            pBar.addSubview(lbl)
            milestoneLabels.append(lbl)

            let config = UIImage.SymbolConfiguration(pointSize: 9, weight: .bold)
            let check = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: config))
            check.tintColor = .white
            check.translatesAutoresizingMaskIntoConstraints = false
            check.alpha = 0
            dot.addSubview(check)
            milestoneCheckmarks.append(check)

            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 20),
                dot.heightAnchor.constraint(equalToConstant: 20),
                dot.centerYAnchor.constraint(equalTo: trackView.centerYAnchor),

                check.centerXAnchor.constraint(equalTo: dot.centerXAnchor),
                check.centerYAnchor.constraint(equalTo: dot.centerYAnchor),

                lbl.topAnchor.constraint(equalTo: dot.bottomAnchor, constant: 4),
                lbl.centerXAnchor.constraint(equalTo: dot.centerXAnchor)
            ])

            if i == 0 {
                dot.leadingAnchor.constraint(equalTo: pBar.leadingAnchor, constant: 6).isActive = true
            } else if i == milestones.count - 1 {
                dot.trailingAnchor.constraint(equalTo: pBar.trailingAnchor, constant: -6).isActive = true
            } else {
                dot.centerXAnchor.constraint(equalTo: pBar.centerXAnchor).isActive = true
            }
        }

        stackView.addArrangedSubview(progressContainer)
    }

    @objc private func didTapDraftScript() {
        guard let idea = analyticsIdea else { return }
        let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)
        guard let chatVC = storyboard.instantiateViewController(withIdentifier: "Chatbot") as? Chatbot else { return }
        chatVC.ideaId = idea.id
        chatVC.autoSendMessage = """
        Create a short creator-style script for this video idea:

        Title: "\(idea.title)"
        Description: "\(idea.hook)"

        Structure:
        1. Hook (1 sentence)
        2. What happens (2–3 sentences)
        3. Twist or surprise (1 sentence)
        4. CTA (1 sentence)

        Tone: casual, friendly, modern.
        Length: 15–20 seconds.
        """
        navigationController?.pushViewController(chatVC, animated: true)
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
                        if let s = script.script, !s.isEmpty { types.insert("script") }
                        if let t = script.title, !t.isEmpty { types.insert("title") }
                        if let d = script.description, !d.isEmpty { types.insert("description") }
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

    private func updateProgressUI() {
        progressViewYourDraftBtn.setTitle(hasExistingScript ? "View Draft" : "Draft Script", for: .normal)

        let typeOrder = ["script", "title", "description"]
        let reordered = typeOrder.filter { completedScriptTypes.contains($0) }
            + typeOrder.filter { !completedScriptTypes.contains($0) }

        for (index, label) in milestoneLabels.enumerated() {
            guard index < reordered.count else { continue }
            label.text = reordered[index].capitalized
        }

        progressWidthConstraint?.isActive = false
        let completedCount = completedScriptTypes.count
        let fraction: CGFloat = completedCount > 0 ? CGFloat(completedCount - 1) / 2.0 : 0.001

        progressWidthConstraint = progressView.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: max(fraction, 0.001))
        progressWidthConstraint?.isActive = true

        for (index, dot) in milestoneDots.enumerated() {
            guard index < reordered.count else { continue }
            let type = reordered[index]
            let isActive = completedScriptTypes.contains(type)

            UIView.animate(withDuration: 0.25) {
                dot.layer.borderColor = isActive ? UIColor.accent.cgColor : UIColor.systemGray3.cgColor
                dot.backgroundColor = isActive ? UIColor.accent : .systemGray5
                self.milestoneCheckmarks[index].alpha = isActive ? 1 : 0
                self.milestoneLabels[index].textColor = isActive ? .accent : .systemGray
                self.milestoneLabels[index].font = .systemFont(ofSize: 11, weight: isActive ? .semibold : .medium)
            }
        }
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}
