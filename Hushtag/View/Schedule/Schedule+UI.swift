import UIKit

extension Schedule {
    func showConnectYouTubePrompt() {
        if emptyStateView != nil { return }

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        emptyStateView = container

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])

        showConnectYouTubePromptContent(in: container)
    }

    private func showConnectYouTubePromptContent(in container: UIView) {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        let imageView = UIImageView(image: UIImage(systemName: "play.rectangle.fill"))
        imageView.tintColor = UIColor(red: 0.545, green: 0.361, blue: 0.965, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = .init(pointSize: 60)

        let titleLabel = UILabel()
        titleLabel.text = "Connect YouTube Account"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .white

        let descLabel = UILabel()
        descLabel.text = "Connect your account to manage your schedule and see automated tasks."
        descLabel.font = .systemFont(ofSize: 16)
        descLabel.textColor = .secondaryLabel
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0

        let connectButton = UIButton(type: .system)
        connectButton.setTitle("Connect Now", for: .normal)
        connectButton.backgroundColor = UIColor(red: 0.545, green: 0.361, blue: 0.965, alpha: 1.0)
        connectButton.setTitleColor(.white, for: .normal)
        connectButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        connectButton.layer.cornerRadius = 25
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        connectButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        connectButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        connectButton.addTarget(self, action: #selector(didTapConnectYouTube), for: .touchUpInside)

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descLabel)
        stackView.addArrangedSubview(connectButton)
    }

    @objc func didTapConnectYouTube() {
        let viewModel = SignInModel()
        Task {
            do {
                try await viewModel.connectYouTube()

                await MainActor.run {
                    CapsuleNotification.show(message: "YouTube Connected!", iconName: "checkmark.circle.fill")
                    self.isYouTubeConnected = true
                    self.updateUIForConnectionStatus()

                    Task {
                        do {
                            try await self.scheduleController.load()
                            await MainActor.run {
                                self.filterItems(for: self.selectedDate)
                                self.scheduleView.reloadSections(IndexSet(integer: 1))
                            }
                        } catch {
                            // error
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Connection Failed",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    func setupRightBarButton() {
        let existingPostAction = UIAction(
            title: "Existing Post",
            image: UIImage(systemName: "doc.text")
        ) { [weak self] _ in
            self?.handleExistingPost()
        }

        let newPostAction = UIAction(title: "New Post", image: UIImage(systemName: "plus.app")) { [weak self] _ in
            self?.handleNewPost()
        }

        let menu = UIMenu(title: "", children: [existingPostAction, newPostAction])
        let rightBarButton = UIBarButtonItem(systemItem: .add, menu: menu)
        navigationItem.rightBarButtonItem = rightBarButton
    }

    func handleExistingPost() {
        let storyboard = UIStoryboard(name: "ExistingPost", bundle: nil)
        if let viewController = storyboard.instantiateViewController(
            withIdentifier: "NavExistingPost"
        ) as? UINavigationController {
            present(viewController, animated: true)
        }
    }

    func handleNewPost() {
        let storyboard = UIStoryboard(name: "CreatePost", bundle: nil)
        if let viewController = storyboard.instantiateViewController(
            withIdentifier: "NavCreatePost"
        ) as? UINavigationController {
            present(viewController, animated: true)
        }
    }

    func registerCell() {
        scheduleView.register(
            UINib(nibName: "ScheduleCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "upcoming_schedule"
        )
        scheduleView.register(
            UINib(nibName: "DetailsCell", bundle: nil),
            forCellWithReuseIdentifier: "schedule_detail"
        )
        scheduleView.register(
            UINib(nibName: "HeaderView", bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "headerCell"
        )
        scheduleView.register(
            UINib(nibName: "HeaderButton", bundle: nil),
            forSupplementaryViewOfKind: "headerButton",
            withReuseIdentifier: "header_button"
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDealsDidChange),
            name: .dealsDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScheduleDidChange),
            name: .scheduleDidChange,
            object: nil
        )
    }

    func showEmptyStateInCollection(message: String, iconName: String) {
        let emptyView = UIView(frame: scheduleView.bounds)

        let imageView = UIImageView(image: UIImage(systemName: iconName))
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = message
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .medium)
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
            stack.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: 50),
            stack.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -40),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 40)
        ])

        scheduleView.backgroundView = emptyView
    }
}
