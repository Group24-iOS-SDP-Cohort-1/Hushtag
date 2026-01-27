//
//  Schedule.swift
//  Hushtag
//
//  Created by SDC-USER on 13/01/26.
//

import UIKit

class Schedule: UIViewController {

    @IBOutlet weak var scheduleView: UICollectionView!
    
    var dataStore: DataStore = DataStore.shared
    private let scheduleController = ScheduleItemController()
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
                print("Failed to load schedule items:", error)
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

                // create the item
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

                // create the group
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(70))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 7)

                //create the section
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
                section.boundarySupplementaryItems = [headerButton]

                return section
        }

            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            
            // create the item
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 7)
            
            // create the group
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(110))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
            
            //create the section
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
    
    private lazy var monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    private var currentMonthText: String {
        monthFormatter.string(from: selectedDate)
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
    
    private func togglePostCompletion(_ post: Post) {
        guard !post.tasks.isEmpty else { return }

        let shouldCompleteAll = !post.tasks.allSatisfy(\.isCompleted)

        let updatedTasks = post.tasks.map { task in
            var t = task
            t.isCompleted = shouldCompleteAll
            return t
        }

        var updatedPost = post
        updatedPost.tasks = updatedTasks

        // TEMP: replace this with Supabase update later
        // scheduleController.updatePost(updatedPost)
    }

    
//    private func toggleDealCompletion(_ deal: Deal) {
//        guard !deal.deliverables.isEmpty else { return }
//
//        let shouldCompleteAll = !deal.isCompleted
//
//        let updatedDeliverables = deal.deliverables.map { d -> Deliverable in
//            var deliverable = d
//            deliverables.isCompleted = shouldCompleteAll
//            return deliverable
//        }
//
//        var updatedDeal = deal
//        updatedDeal.deliverables = updatedDeliverables
//
//        DataStore.shared.updateDeal(updatedDeal)
//    }
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
        }
    }
    
}

extension Notification.Name {
    static let calendarSwipeLeft = Notification.Name("calendarSwipeLeft")
    static let calendarSwipeRight = Notification.Name("calendarSwipeRight")
}

extension Schedule: ScheduleCollectionViewCellDelegate {

    func didTapCompleted(item: ScheduleItem?) {
        guard let item else { return }

        switch item {
        case .post:
            print("Post completion tapped – hook API here")
        case .deal:
            print("Deal completion tapped – hook API here")
        }

        filterItems(for: selectedDate)
        scheduleView.reloadSections(IndexSet(integer: 1))
    }

    }


