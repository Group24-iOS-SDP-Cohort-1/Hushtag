//
//  Overview-Main.swift
//  Hushtag
//
//  Created by SDC-USER on 17/11/25.
//

import UIKit
class Overview: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    enum ScheduleItem {
        case task(Task)
        case deal(Deal)
        case post(Post)

        func date() -> Date? {
            switch self {
            case .task(let task):
                return task.startDate.toDate()
            case .deal(let deal):
                return deal.deliverable.first?.deadline.toDate()
            case .post(let post):
                return post.postingTime.toDate()
            }
        }
    }

    var ideaResponse = IdeaResponse()

    var dataStore: DataStore = DataStore.shared
    
    var analysis: [Analysis] = []
    var post: [Post] = []
    var task: [Task] = []
    var deal: [Deal] = []
    var ideas: [Idea] = []
    var selectedIndexPath: IndexPath?
    var selectedScheduleItem: ScheduleItem?

    var activities: [(String, Int, String)] = []
    var lists: [(String, Int)] = []

    var filteredSchedule: [ScheduleItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        // fetch the data
        
        post = dataStore.getPosts()
        task = dataStore.getTasks()
        deal = dataStore.getDeals()
        
        analysis = dataStore.getAnalysis().prefix(1).map { $0 }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        
    }
    func registerCell() {
        collectionView.register(
            UINib (
                nibName: "Analytics",
                bundle: nil
                 ),
            forCellWithReuseIdentifier: "analysis_cell"
        )
        
        collectionView.register(
            UINib (
                nibName: "ScheduleCollectionViewCell",
                bundle: nil
                 ),
            forCellWithReuseIdentifier: "upcoming_schedule"
        )
        
        collectionView.register(
            UINib(nibName: "HeaderView",
                  bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "headerCell")
        
        collectionView.register(
            UINib(nibName: "HeaderButton",
                  bundle: nil),
            forSupplementaryViewOfKind: "headerButton",
            withReuseIdentifier: "header_button")

    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            section, env in
            
            //define the size of the header view
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
            
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
            
            let headerButton = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "headerButton", alignment: .top)

            if section == 0 {

                // set the item size
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))

                // create the item
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 7, bottom: 2, trailing: 7)

                // create the group
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(130))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)

                //create the section
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom:10, trailing: 20)

                return section
            } else if section == 1 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                
                // create the item
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7)
                
                // create the group
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                
                //create the section
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                section.boundarySupplementaryItems = [headerButton]
                
                return section
            }
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            
            // create the item
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 7, bottom: 7, trailing: 7)
            
            // create the group
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
            
            //create the section
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
            section.boundarySupplementaryItems = [headerItem]

            return section
        }
        return layout
    }
    
    func filterSection(by selectedDate: Date) {
        let calendar = Calendar.current

        let dailyPosts = post
            .filter {
                guard let d = $0.postingTime.toDate() else { return false }
                return calendar.isDate(d, inSameDayAs: selectedDate)
            }
            .map { ScheduleItem.post($0) }

        let dailyTasks = task
            .filter {
                guard let d = $0.startDate.toDate() else { return false }
                return calendar.isDate(d, inSameDayAs: selectedDate)
            }
            .map { ScheduleItem.task($0) }

        let dailyDeals = deal
            .filter { deal in
                deal.deliverable.contains {
                    guard let d = $0.deadline.toDate() else { return false }
                    return calendar.isDate(d, inSameDayAs: selectedDate)
                }
            }
            .map { ScheduleItem.deal($0) }

        filteredSchedule = (dailyPosts + dailyTasks + dailyDeals)
            .sorted {
                ($0.date() ?? .distantFuture) < ($1.date() ?? .distantFuture)
            }

        collectionView.reloadSections(IndexSet(integer: 2))
    }

    
    func tasks(on date: Date) -> [Task] {
        let calendar = Calendar.current
        return task.filter {
            guard let start = $0.startDate.toDate() else { return false }
            return calendar.isDate(start, inSameDayAs: date)
        }
    }

    func completedTasks(on date: Date) -> [Task] {
        tasks(on: date).filter { $0.isCompleted }
    }

    func deals(on date: Date) -> [Deal] {
        let calendar = Calendar.current

        return deal.filter { deal in
            deal.deliverable.contains {
                guard let deadline = $0.deadline.toDate() else { return false }
                return calendar.isDate(deadline, inSameDayAs: date)
            }
        }
    }

    func completedDeals(on date: Date) -> [Deal] {
        deals(on: date).filter {
            let total = $0.deliverable.count
            let completed = $0.deliverable.filter { $0.isCompleted }.count
            return total > 0 && completed == total
        }
    }

    func posts(on date: Date) -> [Post] {
        let calendar = Calendar.current
        return post.filter {
            guard let postDate = $0.postingTime.toDate() else { return false }
            return calendar.isDate(postDate, inSameDayAs: date)
        }
    }

    func completedPosts(on date: Date) -> [Post] {
        posts(on: date).filter { $0.isCompleted }
    }

    func updateActivities(for selectedDate: Date) {

        let dailyTasks = tasks(on: selectedDate)
        let dailyDeals = deals(on: selectedDate)
        let dailyPosts = posts(on: selectedDate)

        let completedDailyTasks = completedTasks(on: selectedDate)
        let completedDailyDeals = completedDeals(on: selectedDate)
        let completedDailyPosts = completedPosts(on: selectedDate)

        let totalActivities =
            dailyTasks.count +
            dailyDeals.count +
            dailyPosts.count

        let totalCompleted =
            completedDailyTasks.count +
            completedDailyDeals.count +
            completedDailyPosts.count

        activities = [
            ("All", totalActivities, "tray.circle.fill"),
            ("Completed", totalCompleted, "checkmark.circle.fill")
        ]

        lists = [
            ("Tasks", dailyTasks.count),
            ("Deals", dailyDeals.count),
            ("Posts", dailyPosts.count)
        ]

        collectionView.reloadSections(IndexSet(integer: 1))
    }

}

extension Overview: UICollectionViewDataSource, UICollectionViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = selectedIndexPath else { return }
        
        if segue.identifier == "goToAnalysis" {
            let vc = segue.destination as! AnalysisDataViewController
            if indexPath.row == 0{
                vc.platform = "YouTube"
                vc.fullAnalysis = dataStore.getAnalysis()
            }
        }
        if segue.identifier == "goToActivities" {
            let vc = segue.destination as! Activities
            vc.posts = post
            vc.deals = deal
            vc.tasks = task
        }
        if segue.identifier == "goToDetails" {
            let vc = segue.destination as! Details
            guard let item = selectedScheduleItem else { return }

            switch item {
            case .post(let post):
                vc.post = post
                vc.task = nil
                vc.deal = nil

            case .task(let task):
                vc.task = task
                vc.post = nil
                vc.deal = nil

            case .deal(let deal):
                vc.deal = deal
                vc.post = nil
                vc.task = nil
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: "goToAnalysis", sender: nil)
        case 1:
            performSegue(withIdentifier: "goToActivities", sender: nil)
        case 2:
            selectedScheduleItem = filteredSchedule[indexPath.row]
            performSegue(withIdentifier: "goToDetails", sender: self)
        default:
            break
        }
    }

    
    // to make 3 sections; by default collection view only has 1 section
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if  (section == 0) {
            return 1
        }
        else if (section == 1) {
            return activities.count
        }
        return filteredSchedule.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "analysis_cell", for: indexPath) as! Analytics
            cell.configure()
            return cell
        }
        else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "schedule_cell",
                for: indexPath
            ) as! ActivitiesCell
            
            let item = activities[indexPath.row]
            cell.configure(item.0, item.1, item.2)
            cell.layer.cornerRadius = 12
            cell.layer.masksToBounds = false
            return cell
        }
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "upcoming_schedule",
            for: indexPath
        ) as! ScheduleCollectionViewCell
        
        let item = filteredSchedule[indexPath.row]

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
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        if kind == "headerButton", indexPath.section == 1 {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: "headerButton",
                withReuseIdentifier: "header_button",
                for: indexPath
            ) as! HeaderButton

            headerView.configure()
            headerView.onDateChanged = { [weak self] selectedDate in
                self?.filterSection(by: selectedDate)
                self?.updateActivities(for: selectedDate)
            }
            return headerView
        }
        
        if kind == "header", indexPath.section == 2 {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: "header",
                withReuseIdentifier: "headerCell",
                for: indexPath
            ) as! HeaderView

            headerView.configureHeader(text: "Upcoming Schedule")
            return headerView
        }


        return UICollectionReusableView()
    }
}


extension UIColor {
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        guard hexString.count == 6 else { return nil }

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
