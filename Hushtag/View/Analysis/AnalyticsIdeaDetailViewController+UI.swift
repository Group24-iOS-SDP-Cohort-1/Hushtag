import UIKit

extension AnalyticsIdeaDetailViewController {
    func setupLayout() {
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

    func populateData() {
        guard let idea = analyticsIdea else { return }
        addHeroCard(idea: idea)
        setupDraftProgressView()
        addStrategyCard(idea: idea)
        addHookCard(idea: idea)
        addThumbnailCard(idea: idea)
        addMetricsGrid(idea: idea)
    }

    func addHeroCard(idea: AnalyticsIdea) {
        let heroCard = createCardView()
        let titleLabel = UILabel()
        titleLabel.text = idea.title
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let metaLabel = UILabel()
        metaLabel.text = "\(idea.format.uppercased()) \u{2022} Virality: \(Int(idea.estimatedViralityScore))"
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
    }

    func addStrategyCard(idea: AnalyticsIdea) {
        let card = createCardView()
        let sectionTitle = createSectionTitle("Why it will work")
        let bodyLabel = UILabel()
        bodyLabel.text = "\u{2022} " + idea.whyItWillWork.joined(separator: "\n\u{2022} ")
        bodyLabel.numberOfLines = 0
        bodyLabel.font = .systemFont(ofSize: 15, weight: .regular)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        let emotionLabel = UILabel()
        emotionLabel.text = "Target Emotion: \(idea.targetEmotion)"
        emotionLabel.font = .systemFont(ofSize: 14, weight: .medium)
        emotionLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(sectionTitle)
        card.addSubview(emotionLabel)
        card.addSubview(bodyLabel)
        NSLayoutConstraint.activate([
            sectionTitle.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            sectionTitle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            emotionLabel.topAnchor.constraint(equalTo: sectionTitle.bottomAnchor, constant: 12),
            emotionLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            bodyLabel.topAnchor.constraint(equalTo: emotionLabel.bottomAnchor, constant: 12),
            bodyLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            bodyLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            bodyLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        stackView.addArrangedSubview(card)
    }

    func addHookCard(idea: AnalyticsIdea) {
        let card = createCardView()
        let sectionTitle = createSectionTitle("Opening Flow")
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
        card.addSubview(sectionTitle)
        card.addSubview(hookLabel)
        card.addSubview(openingLabel)
        NSLayoutConstraint.activate([
            sectionTitle.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            sectionTitle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            hookLabel.topAnchor.constraint(equalTo: sectionTitle.bottomAnchor, constant: 12),
            hookLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            hookLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            openingLabel.topAnchor.constraint(equalTo: hookLabel.bottomAnchor, constant: 12),
            openingLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            openingLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            openingLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        stackView.addArrangedSubview(card)
    }

    func addThumbnailCard(idea: AnalyticsIdea) {
        guard let thumb = idea.thumbnailConcept else { return }
        let card = createCardView()
        let sectionTitle = createSectionTitle("Thumbnail Concept")
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
        card.addSubview(sectionTitle)
        card.addSubview(vStack)
        NSLayoutConstraint.activate([
            sectionTitle.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            sectionTitle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            vStack.topAnchor.constraint(equalTo: sectionTitle.bottomAnchor, constant: 12),
            vStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            vStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        stackView.addArrangedSubview(card)
    }

    func addMetricsGrid(idea: AnalyticsIdea) {
        stackView.addArrangedSubview(createSectionTitle("Performance Estimations"))
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
        leftCol.addArrangedSubview(createMetricCard(
            title: "Virality",
            value: "\(Int(idea.estimatedViralityScore))/100"
        ))
        rightCol.addArrangedSubview(createMetricCard(
            title: "Retention",
            value: "\(Int(idea.estimatedRetention * 100))%"
        ))
        rightCol.addArrangedSubview(createMetricCard(title: "Difficulty", value: idea.difficulty.capitalized))
        gridStack.addArrangedSubview(leftCol)
        gridStack.addArrangedSubview(rightCol)
        stackView.addArrangedSubview(gridStack)
    }

    func createCardView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.5)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func createSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func createMetricCard(title: String, value: String) -> UIView {
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
}
