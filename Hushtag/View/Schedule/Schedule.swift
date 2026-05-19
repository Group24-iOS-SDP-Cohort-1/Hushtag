import UIKit

class Schedule: UIViewController {
    @IBOutlet var scheduleView: UICollectionView!
    let scheduleController = ScheduleItemController()
    let postsController = PostsController()
    let dealsController = DealsController()
    var todayItems: [ScheduleItem] = []
    var selectedDate: Date = .init()
    var weekDates: [Date] = []
    var selectedScheduleItem: ScheduleItem?
    var isYouTubeConnected: Bool = true
    var emptyStateView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        checkConnectionStatus()
        setupRightBarButton()
        
        scheduleView.delegate = self
        scheduleView.dataSource = self
        scheduleView.setCollectionViewLayout(generateLayout(), animated: true)
        registerCell()
        generateWeek(for: selectedDate)
        filterItems(for: selectedDate)
        updateEmptyState()
        scheduleView.reloadSections(IndexSet(integer: 1))
        
        Task {
            do {
                try await scheduleController.load()
                
                await MainActor.run {
                    self.filterItems(for: self.selectedDate)
                    self.updateEmptyState()
                    self.scheduleView.reloadSections(IndexSet(integer: 1))
                }
            } catch {
                // print("Failed to load schedule items:", error)
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCalendarLeft),
            name: .calendarSwipeLeft,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCalendarRight),
            name: .calendarSwipeRight,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkConnectionStatus()
    }
    
    private func checkConnectionStatus() {
        Task {
            let connected = await YouTubeController.shared.checkYouTubeConnection()
            await MainActor.run {
                self.isYouTubeConnected = connected
                self.updateUIForConnectionStatus()
            }
        }
    }
    
    private func updateUIForConnectionStatus() {
        if isYouTubeConnected {
            emptyStateView?.removeFromSuperview()
            emptyStateView = nil
            scheduleView.isHidden = false
            setupRightBarButton()
        } else {
            showConnectYouTubePrompt()
            scheduleView.isHidden = true
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func showConnectYouTubePrompt() {
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
    
    @objc private func didTapConnectYouTube() {
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
                            // print("Failed to load schedule items after connection:", error)
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
    
    private func setupRightBarButton() {
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
    
    private func handleExistingPost() {
        let storyboard = UIStoryboard(name: "ExistingPost", bundle: nil)
        if let navigationVC =
            storyboard.instantiateViewController(withIdentifier: "NavExistingPost")
            as? UINavigationController {
            present(navigationVC, animated: true)
        }
    }
    
    private func handleNewPost() {
        let storyboard = UIStoryboard(name: "CreatePost", bundle: nil)
        if let navigationVC =
            storyboard.instantiateViewController(withIdentifier: "NavCreatePost")
            as? UINavigationController {
            present(navigationVC, animated: true)
        }
    }
    
    func registerCell() {
        scheduleView.register(
            UINib(
                nibName: "ScheduleCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "upcoming_schedule"
        )
        
        scheduleView.register(
            UINib(
                nibName: "DetailsCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "schedule_detail"
        )
        
        scheduleView.register(
            UINib(
                nibName: "HeaderView",
                bundle: nil
            ),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "headerCell"
        )
        
        scheduleView.register(
            UINib(
                nibName: "HeaderButton",
                bundle: nil
            ),
            forSupplementaryViewOfKind: "headerButton",
            withReuseIdentifier: "header_button"
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePostsDidChange),
            name: .postsDidChange,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDealsDidChange),
            name: .dealsDidChange,
            object: nil
        )
    }
    
    private func filterItems(for date: Date) {
        selectedDate = date
        todayItems = scheduleController.scheduleItems(on: date)
    }
    
    func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { section, _ in
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(50)
            )
            
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: "header",
                alignment: .top
            )
            
            let headerButton = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: "headerButton",
                alignment: .top
            )
            
            if section == 0 {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0 / 7.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(70)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 7)
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
                section.boundarySupplementaryItems = [headerButton]
                
                return section
            }
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 7)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(110)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
            section.boundarySupplementaryItems = [headerItem]
            
            return section
        }
    }
    
    func generateWeek(for date: Date) {
        let calendar = Calendar.current
        
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)!.start
        
        weekDates = (0 ..< 7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startOfWeek)
        }
        
        scheduleView.reloadSections(IndexSet(integer: 0))
    }
    
    var currentMonthText: String {
        selectedDate.monthAndYear()
    }
    
    func changeWeek(by value: Int) {
        let calendar = Calendar.current
        
        guard let newDate = calendar.date(byAdding: .weekOfYear, value: value, to: selectedDate) else {
            return
        }
        
        selectedDate = newDate
        generateWeek(for: selectedDate)
        filterItems(for: selectedDate)
        
        scheduleView.performBatchUpdates {
            scheduleView.reloadSections(IndexSet([0, 1]))
        }
    }
    
    func changeMonth(to date: Date) {
        selectedDate = date
        generateWeek(for: selectedDate)
        filterItems(for: selectedDate)
        
        scheduleView.performBatchUpdates {
            scheduleView.reloadSections(IndexSet([0, 1]))
        }
    }
    
    @objc private func handleCalendarLeft() {
        changeWeek(by: 1)
    }
    
    @objc private func handleCalendarRight() {
        changeWeek(by: -1)
    }
    
    func handleTaskToggle(
        post: Post,
        task: Tasks
    ) async {
        let optimisticPost: Post = {
            var copy = post
            copy.tasks = post.tasks.map {
                var taskItem = $0
                if taskItem.id == task.id {
                    taskItem.isCompleted.toggle()
                }
                return taskItem
            }
            return copy
        }()
        
        scheduleController.replacePost(optimisticPost)
        filterItems(for: selectedDate)
        
        await MainActor.run {
            scheduleView.reloadSections(IndexSet(integer: 1))
        }
        
        do {
            let savedPost = try await ToggleService.toggleTask(
                post: post,
                task: task,
                postsController: postsController
            )
            
            scheduleController.replacePost(savedPost)
            filterItems(for: selectedDate)
            
            await MainActor.run {
                scheduleView.reloadSections(IndexSet(integer: 1))
            }
            
        } catch {
            scheduleController.replacePost(post)
            filterItems(for: selectedDate)
            
            await MainActor.run {
                scheduleView.reloadSections(IndexSet(integer: 1))
            }
            
            // print("❌ Failed to toggle task:", error)
        }
    }
    
    func handleDeliverableToggle(
        deal: Deal,
        deliverable: Deliverable
    ) async {
        let optimisticDeal: Deal = {
            var copy = deal
            copy.deliverables = deal.deliverables.map {
                var deliverableItem = $0
                if deliverableItem.id == deliverable.id {
                    deliverableItem.isCompleted.toggle()
                }
                return deliverableItem
            }
            return copy
        }()
        
        scheduleController.replaceDeal(optimisticDeal)
        filterItems(for: selectedDate)
        
        await MainActor.run {
            scheduleView.reloadSections(IndexSet(integer: 1))
        }
        
        do {
            let savedDeal = try await ToggleService.toggleDeliverable(
                deal: deal,
                deliverable: deliverable,
                dealsController: dealsController
            )
            
            scheduleController.replaceDeal(savedDeal)
            filterItems(for: selectedDate)
            
            await MainActor.run {
                scheduleView.reloadSections(IndexSet(integer: 1))
            }
            
        } catch {
            scheduleController.replaceDeal(deal)
            filterItems(for: selectedDate)
            
            await MainActor.run {
                scheduleView.reloadSections(IndexSet(integer: 1))
            }
            
            // print("❌ Failed to toggle deliverable:", error)
        }
    }
    
    func handleMainPostToggle(post: Post) async {
        let optimisticPost: Post = {
            var copy = post
            copy.isManuallyCompleted.toggle()
            let newStatus = copy.isManuallyCompleted
            copy.tasks = copy.tasks.map {
                var taskItem = $0
                taskItem.isCompleted = newStatus
                return taskItem
            }
            return copy
        }()
        
        scheduleController.replacePost(optimisticPost)
        filterItems(for: selectedDate)
        
        await MainActor.run {
            scheduleView.reloadSections(IndexSet(integer: 1))
        }
        
        do {
            let savedPost = try await ToggleService.toggleMainPost(
                post: post,
                postsController: postsController
            )
            
            scheduleController.replacePost(savedPost)
            filterItems(for: selectedDate)
            
            await MainActor.run {
                scheduleView.reloadSections(IndexSet(integer: 1))
            }
        } catch {
            scheduleController.replacePost(post)
            filterItems(for: selectedDate)
            
            await MainActor.run {
                scheduleView.reloadSections(IndexSet(integer: 1))
            }
        }
    }
    
    func handleMainDealToggle(deal: Deal) async {
        let optimisticDeal: Deal = {
            var copy = deal
            copy.isManuallyCompleted.toggle()
            let newStatus = copy.isManuallyCompleted
            copy.deliverables = copy.deliverables.map {
                var deliverableItem = $0
                deliverableItem.isCompleted = newStatus
                return deliverableItem
            }
            return copy
        }()
        
        scheduleController.replaceDeal(optimisticDeal)
        filterItems(for: selectedDate)
        
        await MainActor.run {
            scheduleView.reloadSections(IndexSet(integer: 1))
        }
        
        do {
            let savedDeal = try await ToggleService.toggleMainDeal(
                deal: deal,
                dealsController: dealsController
            )
            
            scheduleController.replaceDeal(savedDeal)
            filterItems(for: selectedDate)
            
            await MainActor.run {
                scheduleView.reloadSections(IndexSet(integer: 1))
            }
        } catch {
            scheduleController.replaceDeal(deal)
            filterItems(for: selectedDate)
            
            await MainActor.run {
                scheduleView.reloadSections(IndexSet(integer: 1))
            }
        }
    }
    
    @objc func handleDealsDidChange() {
        Task {
            do {
                try await scheduleController.load()
                
                await MainActor.run {
                    self.filterItems(for: self.selectedDate)
                    self.updateEmptyState()
                    self.scheduleView.reloadSections(IndexSet(integer: 1))
                }
                
            } catch {
                // print("❌ Failed to reload deals:", error)
            }
        }
    }
    
    @objc private func handlePostsDidChange() {
        Task {
            do {
                try await scheduleController.load()
                
                await MainActor.run {
                    self.filterItems(for: self.selectedDate)
                    self.updateEmptyState()
                    self.scheduleView.reloadSections(IndexSet(integer: 1))
                }
                
            } catch {
                // print("❌ Failed to reload posts:", error)
            }
        }
    }
    
    func updateEmptyState() {
        if todayItems.isEmpty {
            showEmptyStateInCollection(message: "No activities scheduled", iconName: "calendar.badge.exclamationmark")
        } else {
            // Check if we didn't show the YouTube prompt
            if isYouTubeConnected {
                scheduleView.backgroundView = nil
            }
        }
    }
    
    private func showEmptyStateInCollection(message: String, iconName: String) {
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
