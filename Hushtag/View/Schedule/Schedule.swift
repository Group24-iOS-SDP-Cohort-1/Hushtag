import UIKit

class Schedule: UIViewController {
    
    @IBOutlet weak var scheduleView: UICollectionView!
    private let scheduleController = ScheduleItemController()
    private let postsController = PostsController()
    private let dealsController = DealsController()
    
    private var todayItems: [ScheduleItem] = []
    
    private var selectedDate: Date = Date()
    private var weekDates: [Date] = []
    private var selectedScheduleItem: ScheduleItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        scheduleView.delegate = self
        scheduleView.dataSource = self
        scheduleView.setCollectionViewLayout(generateLayout(), animated: true)
        registerCell()
        generateWeek(for: selectedDate)
        filterItems(for: selectedDate)
        scheduleView.reloadSections(IndexSet(integer: 1))
        
        Task {
            do {
                try await scheduleController.load()
                
                await MainActor.run {
                    self.filterItems(for: self.selectedDate)
                    self.scheduleView.reloadSections(IndexSet(integer: 1))
                }
            } catch {
                //print("Failed to load schedule items:", error)
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
    
    func registerCell() {
        scheduleView.register(
            UINib (
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
            withReuseIdentifier: "headerCell")
        
        scheduleView.register(
            UINib(
                nibName: "HeaderButton",
                bundle: nil
            ),
            forSupplementaryViewOfKind: "headerButton",
            withReuseIdentifier: "header_button")
        
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
        let layout = UICollectionViewCompositionalLayout {
            section, env in
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
            
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
            
            let headerButton = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "headerButton", alignment: .top)
            
            if section == 0 {
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 7.0), heightDimension: .fractionalHeight(1.0))
                
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(70))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 7)
                
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
                section.boundarySupplementaryItems = [headerButton]
                
                return section
            }
            
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 7)
            
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(110))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
            
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
            section.boundarySupplementaryItems = [headerItem]
            
            return section
        }
        return layout
    }
    
    private func generateWeek(for date: Date) {
        let calendar = Calendar.current
        
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)!.start
        
        weekDates = (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startOfWeek)
        }
        
        scheduleView.reloadSections(IndexSet(integer: 0))
    }
    
    
    
    private var currentMonthText: String {
        selectedDate.monthAndYear()
    }
    
    private func changeWeek(by value: Int) {
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
    
    private func changeMonth(to date: Date) {
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
    
    private func handleTaskToggle(
        post: Post,
        task: Tasks
    ) async {
        
        
        let optimisticPost: Post = {
            var copy = post
            copy.tasks = post.tasks.map {
                var t = $0
                if t.id == task.id {
                    t.isCompleted.toggle()
                }
                return t
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
            
            //print("❌ Failed to toggle task:", error)
        }
    }
    
    private func handleDeliverableToggle(
        deal: Deal,
        deliverable: Deliverable
    ) async {
        
        let optimisticDeal: Deal = {
            var copy = deal
            copy.deliverables = deal.deliverables.map {
                var d = $0
                if d.id == deliverable.id {
                    d.isCompleted.toggle()
                }
                return d
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
            
            //print("❌ Failed to toggle deliverable:", error)
        }
    }
    
    
    @objc private func handleDealsDidChange() {
        Task {
            do {
                try await scheduleController.load()
                
                await MainActor.run {
                    self.filterItems(for: self.selectedDate)
                    self.scheduleView.reloadSections(IndexSet(integer: 1))
                }
                
            } catch {
                //print("❌ Failed to reload deals:", error)
            }
        }
    }
    
    @objc private func handlePostsDidChange() {
        Task {
            do {
                try await scheduleController.load()
                
                await MainActor.run {
                    self.filterItems(for: self.selectedDate)
                    self.scheduleView.reloadSections(IndexSet(integer: 1))
                }
                
            } catch {
                //print("❌ Failed to reload posts:", error)
            }
        }
    }
}

extension Schedule: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return weekDates.count
        }
        return todayItems.isEmpty ? 1 : todayItems.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "calendar",
                for: indexPath
            ) as! CalendarCell
            
            let date = weekDates[indexPath.row]
            let calendar = Calendar.current
            
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d"
            
            let dayText = dayFormatter.string(from: date).uppercased()
            let dateText = dateFormatter.string(from: date)
            
            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
            
            cell.configure(
                day: dayText,
                date: dateText,
                isSelected: isSelected
            )
            
            return cell
        }
        
        if todayItems.isEmpty {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "blankCell",
                for: indexPath
            )
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "upcoming_schedule",
            for: indexPath
        ) as! ScheduleCollectionViewCell
        
        let item = todayItems[indexPath.row]
        cell.delegate = self
        cell.indexPath = indexPath
        cell.configure(with: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == "header", indexPath.section == 1 {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: "header",
                withReuseIdentifier: "headerCell",
                for: indexPath
            ) as! HeaderView
            
            headerView.configureHeader(text: "Activities Overview")
            return headerView
        }
        
        if kind == "headerButton", indexPath.section == 0 {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: "headerButton",
                withReuseIdentifier: "header_button",
                for: indexPath
            ) as! HeaderButton
            
            headerView.configure(text: currentMonthText, date: selectedDate)
            
            headerView.onDateChanged = { [weak self] newDate in
                self?.changeMonth(to: newDate)
            }
            
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            selectedDate = weekDates[indexPath.row]
            todayItems = scheduleController.scheduleItems(on: selectedDate)
            
            collectionView.performBatchUpdates {
                collectionView.reloadSections(IndexSet([0, 1]))
            }
            return
        }
        
        guard indexPath.section == 1,
              !todayItems.isEmpty else { return }
        
        selectedScheduleItem = todayItems[indexPath.row]
        performSegue(withIdentifier: "goToDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetails" {
            let vc = segue.destination as! Details
            vc.schedule = selectedScheduleItem
            vc.onToggleTask = { [weak self, weak vc] post, task in
                Task {
                    await self?.handleTaskToggle(post: post, task: task)
                    
                    if let updated = self?.scheduleController
                        .scheduleItems(on: self!.selectedDate)
                        .first(where: { $0.matches(post: post, task: task) }) {
                        
                        await MainActor.run {
                            vc?.schedule = updated
                            vc?.detailsView.reloadData()
                        }
                    }
                }
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

extension Schedule: ScheduleCollectionViewCellDelegate {
    
    func didTapCompleted(item: ScheduleItem, indexPath: IndexPath) {
        
        Task {
            switch item {
                
            case .post(let post, let task):
                if let task = task {
                    
                    await handleTaskToggle(post: post, task: task)
                } else {
                    //print("Main Post tapped")
                }
                
            case .deal(let deal, let deliverable):
                if let deliverable = deliverable {
                    
                    await handleDeliverableToggle(deal: deal, deliverable: deliverable)
                } else {
                    
                    //print("Main Deal tapped")
                }
            }
        }
    }
}
