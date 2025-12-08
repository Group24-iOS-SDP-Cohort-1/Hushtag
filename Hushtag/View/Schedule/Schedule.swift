//
//  ScheduleViewController.swift
//  Hushtag
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class Schedule: UIViewController {

    @IBOutlet weak var activitiesView: UICollectionView!
    @IBOutlet weak var listView: UITableView!
    
    
    var tasks: [Task]?
    var deals: [Deal]?
    var posts: [Post]?
    var activities: [(String, Int, String)] = []
    var lists: [(String, Int)] = []
    var completedDeals: [Deal] {
        return deals?.filter {
            let total = $0.deliverable.count
            let completed = $0.deliverable.filter { $0.isCompleted }.count
            return total > 0 && completed == total
        } ?? []
    }

    var completedTasks: [Task] {
        return tasks?.filter { $0.isCompleted } ?? []
    }

    var completedPosts: [Post] {
        return posts?.filter { $0.isCompleted } ?? []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let taskCount = tasks?.count ?? 0
        let dealCount = deals?.count ?? 0
        let postCount = posts?.count ?? 0

        activities = [
            ("All", taskCount + dealCount + postCount, "tray.circle.fill"),
            ("Completed", completedTasks.count + completedDeals.count + completedPosts.count, "checkmark.circle.fill")
        ]

        lists = [
            ("Tasks", taskCount),
            ("Deals", dealCount),
            ("Posts", postCount)
        ]
        
        activitiesView.setCollectionViewLayout(generateLayout(), animated: true)
        activitiesView.dataSource = self
        activitiesView.delegate = self
        listView.dataSource = self
        listView.delegate = self
        listView.register(UINib(nibName: "listsCell", bundle: nil), forCellReuseIdentifier: "listCell")
    }
    func navigateToActivitiesStoryboard() {
        performSegue(withIdentifier: "GoToActivitiesSegue", sender: self)
        
//        let vc = storyboard?.instantiateViewController(withIdentifier: "Activities") as! Activities
//            navigationController?.pushViewController(vc, animated: true)
        
    }

}

extension Schedule: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = activitiesView.dequeueReusableCell(withReuseIdentifier: "ScheduleCell", for: indexPath) as! ActivitiesCell
        let item = activities[indexPath.row]
        cell.configure(item.0, item.1, item.2)
        return cell
    }
    
    func generateLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        // create the item
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7)
        
        // create the group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        
        //create the section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom:10, trailing: 0)
        //section.boundarySupplementaryItems = [headerButton]
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension Schedule: UITableViewDataSource, UITableViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToActivitiesSegue",
           let vc = segue.destination as? Activities,
           let category = sender as? String {

            vc.category = category
            
            switch category {
            case "Tasks":
                vc.tasks = tasks ?? []
            case "Deals":
                vc.deals = deals ?? []
            case "Posts":
                vc.posts = posts ?? []
            default:
                break
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToActivitiesSegue", sender: indexPath.row)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! listsCell
        let item = lists[indexPath.row]
        cell.configure(lists: item)

        cell.onTap = { [weak self] in
        guard let self = self else { return }

        switch indexPath.row {
            case 0:
               self.performSegue(withIdentifier: "GoToActivitiesSegue", sender: "Tasks")
            case 1:
               self.performSegue(withIdentifier: "GoToActivitiesSegue", sender: "Deals")
            case 2:
               self.performSegue(withIdentifier: "GoToActivitiesSegue", sender: "Posts")
            default:
               break
            }
       }
       return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}
