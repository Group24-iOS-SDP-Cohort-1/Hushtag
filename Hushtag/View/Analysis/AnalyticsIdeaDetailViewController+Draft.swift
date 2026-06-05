import UIKit

extension AnalyticsIdeaDetailViewController {
    func setupDraftProgressView() {
        setupDraftProgressHeader()
        setupDraftProgressDots()
        stackView.addArrangedSubview(progressContainer)
    }

    private func setupDraftProgressHeader() {
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
            progressViewYourDraftBtn.leadingAnchor.constraint(
                equalTo: progressContainer.leadingAnchor, constant: 16
            ),
            progressViewYourDraftBtn.trailingAnchor.constraint(
                equalTo: progressContainer.trailingAnchor, constant: -16
            ),
            progressViewYourDraftBtn.bottomAnchor.constraint(
                equalTo: progressContainer.bottomAnchor, constant: -16
            ),
            progressViewYourDraftBtn.heightAnchor.constraint(equalToConstant: 44)
        ])

        setupInnerTrack(in: pBar)
    }

    private func setupInnerTrack(in pBar: UIView) {
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
    }

    private func setupDraftProgressDots() {
        guard let pBar = trackView.superview else { return }
        let milestones = ["Script", "Title", "Description"]
        for (index, milestone) in milestones.enumerated() {
            let dot = UIView()
            dot.backgroundColor = .systemGray5
            dot.layer.cornerRadius = 10
            dot.layer.borderWidth = 2
            dot.layer.borderColor = UIColor.systemGray3.cgColor
            dot.translatesAutoresizingMaskIntoConstraints = false
            pBar.addSubview(dot)
            milestoneDots.append(dot)

            let lbl = UILabel()
            lbl.text = milestone
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

            if index == 0 {
                dot.leadingAnchor.constraint(equalTo: pBar.leadingAnchor, constant: 6).isActive = true
            } else if index == milestones.count - 1 {
                dot.trailingAnchor.constraint(equalTo: pBar.trailingAnchor, constant: -6).isActive = true
            } else {
                dot.centerXAnchor.constraint(equalTo: pBar.centerXAnchor).isActive = true
            }
        }
    }

    @objc func didTapDraftScript() {
        guard let idea = analyticsIdea else { return }

        let ideaKey = makeIdeaKey(
            title: idea.title,
            description: idea.hook,
            format: idea.format,
            hashtags: []
        )
        let convertedIdea = Idea(
            id: idea.id,
            ideaKey: ideaKey,
            title: idea.title,
            description: idea.hook,
            format: idea.format,
            hashtags: [],
            noveltyScore: Int(idea.estimatedViralityScore),
            videos: nil,
            liked: false
        )

        Task {
            do {
                try await ScriptedIdeasController().insertIdeaIfNeeded(idea: convertedIdea)
            } catch {
                print("⚠️ Failed to insert analytics idea:", error)
            }

            await MainActor.run {
                let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)
                guard let chatVC = storyboard.instantiateViewController(
                    withIdentifier: "Chatbot"
                ) as? Chatbot else { return }
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
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
        }
    }

    func updateProgressUI() {
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

        progressWidthConstraint = progressView.widthAnchor.constraint(
            equalTo: trackView.widthAnchor,
            multiplier: max(fraction, 0.001)
        )
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
