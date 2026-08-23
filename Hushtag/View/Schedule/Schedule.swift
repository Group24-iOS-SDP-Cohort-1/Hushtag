import UIKit

class Schedule: UIViewController {
    @IBOutlet var scheduleView: UICollectionView!
    let scheduleController = ScheduleItemController()
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

    func checkConnectionStatus() {
        Task {
            let connected = await YouTubeController.shared.checkYouTubeConnection()
            await MainActor.run {
                self.isYouTubeConnected = connected
                self.updateUIForConnectionStatus()
            }
        }
    }

    func updateUIForConnectionStatus() {
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

    func filterItems(for date: Date) {
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
        guard let newDate = calendar.date(byAdding: .weekOfYear, value: value, to: selectedDate) else { return }
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

    @objc func handleCalendarLeft() {
        changeWeek(by: 1)
    }

    @objc func handleCalendarRight() {
        changeWeek(by: -1)
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
                // error
            }
        }
    }

    func updateEmptyState() {
        if todayItems.isEmpty {
            showEmptyStateInCollection(message: "No activities scheduled", iconName: "calendar.badge.exclamationmark")
        } else {
            if isYouTubeConnected {
                scheduleView.backgroundView = nil
            }
        }
    }
}

extension Notification.Name {
    static let calendarSwipeLeft = Notification.Name("calendarSwipeLeft")
    static let calendarSwipeRight = Notification.Name("calendarSwipeRight")
    static let scheduleDidChange = Notification.Name("scheduleDidChange")
    static let postsDidChange = Notification.Name("postsDidChange")
    static let dealsDidChange = Notification.Name("dealsDidChange")
}
