//
//  ScheduleViewController.swift
//  Hushtag
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class Schedule: UIViewController {

    @IBOutlet weak var activitiesView: UICollectionView!
    let activity = ["All", "Completed"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        activitiesView.delegate = self
        activitiesView.dataSource = self
        activitiesView.setCollectionViewLayout(generateLayout(), animated: true)
    }
    
}
extension Schedule: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = activitiesView.dequeueReusableCell(withReuseIdentifier: "ScheduleCell", for: indexPath) as! ActivitiesCell
        let act = activity[indexPath.item]
        cell.configure(activity[indexPath.item], 4)
        return cell
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        // create the item
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7)
        
        // create the group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        
        //create the section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom:10, trailing: 20)
        //section.boundarySupplementaryItems = [headerButton]
        
        return UICollectionViewLayout()
    }
}
