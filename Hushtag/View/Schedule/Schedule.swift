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
    
    var postresponse = PostResponse()
    var taskresponse = TaskResponse()
    var dealsresponse = DealResponse()
    var tasks: [Task] = []
    var deals: [Deal] = []
    var posts: [Post] = []
    var activities: [(String, Int, String)] = []
    var lists: [(String, Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tasks = taskresponse.tasks
        deals = dealsresponse.deals
        posts = postresponse.posts
        print(tasks, "\n", deals,"\n", posts)
        activities = [
            ("All", tasks.count + deals.count + posts.count, "tray.circle.fill"),
            ("Completed", 2, "checkmark.circle.fill")
        ]
        lists = [
            ("Tasks", tasks.count),
            ("Deals", deals.count),
            ("Posts", posts.count)
        ]
        
        activitiesView.setCollectionViewLayout(generateLayout(), animated: true)
        activitiesView.dataSource = self
        activitiesView.delegate = self
        listView.dataSource = self
        listView.delegate = self
        listView.register(UINib(nibName: "listsCell", bundle: nil), forCellReuseIdentifier: "listCell")
    }
    
}
extension Schedule: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = activitiesView.dequeueReusableCell(withReuseIdentifier: "ScheduleCell", for: indexPath) as! ActivitiesCell
        let item = activities[indexPath.item]
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! listsCell
        let item = lists[indexPath.item]
        cell.configure(lists: item)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}
