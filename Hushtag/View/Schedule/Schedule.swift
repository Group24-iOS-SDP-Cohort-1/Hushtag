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
    var scheduleItem: [ScheduleItem]?
    private var todayItems: [ScheduleItem] = []
    private var selectedDate: Date = Date()
    private var weekDates: [Date] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        scheduleView.delegate = self
        scheduleView.dataSource = self
        scheduleView.setCollectionViewLayout(generateLayout(), animated: true)
        registerCell()
        generateWeek(for: selectedDate)
        filterItems(for: selectedDate)
        scheduleView.reloadSections(IndexSet(integer: 1))
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
            UINib(nibName: "HeaderView",
                  bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "headerCell")
    }
    private func filterItems(for date: Date) {
        selectedDate = date
        todayItems = dataStore.scheduleItems(on: date)
    }

    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            section, env in
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
            
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
            
            if section == 0 {

                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))

                // create the item
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 7, bottom: 2, trailing: 7)

                // create the group
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.12), heightDimension: .estimated(70))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)

                //create the section
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom:10, trailing: 20)
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
            //section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
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

}

extension Schedule: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return weekDates.count
        }
        return todayItems.count
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


        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "upcoming_schedule",
            for: indexPath
        ) as! ScheduleCollectionViewCell

        let item = todayItems[indexPath.row]
        switch item {
        case .post(let post):
            cell.configureCell(post, nil, nil)
        case .task(let task):
            cell.configureCell(nil, nil, task)
        case .deal(let deal):
            cell.configureCell(nil, deal, nil)
        }

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
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard indexPath.section == 0 else { return }

        selectedDate = weekDates[indexPath.row]
        todayItems = dataStore.scheduleItems(on: selectedDate)

        collectionView.performBatchUpdates {
            collectionView.reloadSections(IndexSet([0, 1]))
        }
    }
}
