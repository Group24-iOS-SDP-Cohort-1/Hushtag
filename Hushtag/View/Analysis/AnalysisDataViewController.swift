//
//  AnalysisDataViewController.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class AnalysisDataViewController: UIViewController {

    var analysisData: Analysis?
    var platform: String = ""
    
    var fullAnalysis: [Analysis] = []
    
    @IBOutlet weak var analysisCollectionView: UICollectionView!
    
    @IBOutlet weak var segmentedTimeOutlet: UISegmentedControl!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "\(platform.capitalized) Analysis"
        analysisCollectionView.dataSource = self
        analysisCollectionView.register(
            UINib (
                nibName: "AnalysisCell", bundle: nil),
                forCellWithReuseIdentifier: "analysis_page_cell"
            )
        
        analysisCollectionView.register(
                UINib(nibName: "AudienceChartCell", bundle: nil),
                forCellWithReuseIdentifier: "gender_analysis_cell"
            )
        
        analysisCollectionView.register(
            UINib(nibName: "HeaderView",
                  bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "headerCell")
        
        let purpleColor = UIColor(red: 139/255, green: 92/255, blue: 246/255, alpha: 1)
        let grayColor = UIColor.darkGray

        segmentedTimeOutlet.selectedSegmentIndex = 0
        
        // Normal (not selected)
        segmentedTimeOutlet.setTitleTextAttributes([
            .foregroundColor: grayColor,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)

        // Selected
        segmentedTimeOutlet.setTitleTextAttributes([
            .foregroundColor: purpleColor,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
        
        let layout = generateAnalysisLayout()
        analysisCollectionView.setCollectionViewLayout(layout, animated: true)
        
        //print(fullAnalysis)
        loadDataFor(segmentIndex: 0)
    }
    
    
    
    //FUNCTION TO LOAD THE DATA FOR THE SELECTED INDEX
    
    func loadDataFor(segmentIndex: Int) {
        let targetID = String(segmentIndex + 1) // Convert 0 -> "1"
            
            // Find the matching object in the full list
        if let selectedData = fullAnalysis.first(where: { $0.id == targetID }) {
            self.analysisData = selectedData
            //print(analysisData)
            // CRITICAL: Reload the collection view to show new data
            self.analysisCollectionView.reloadData()
            
            //print("Switched to ID: \(targetID)")
        } else {
            print("Could not find data for ID: \(targetID)")
        }
    }
    
    //FUNCTION TO CHANGE DATA WHEN THE SELECTED SEGMENT CHANGES
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        loadDataFor(segmentIndex: sender.selectedSegmentIndex)
        
    }
    

}

extension AnalysisDataViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 3
        }else{
            return 1
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gender_analysis_cell", for: indexPath) as! AudienceChartCell
                    
            if let data = analysisData {
                cell.configure(with: data)
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "analysis_page_cell", for: indexPath) as! AnalysisCell
        
        guard let analysisDataUnwrapped = analysisData else { return cell }
        
        
        if indexPath.row == 0{
            cell.configureCell(value: analysisDataUnwrapped.likes, type: "Likes")
        }else if indexPath.row == 1{
            cell.configureCell(value: analysisDataUnwrapped.views, type: "Views")
        }else{
            cell.configureCell(value: analysisDataUnwrapped.followers, type: "Followers")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: "header",
            withReuseIdentifier: "headerCell",
            for: indexPath
        ) as! HeaderView
        
        if indexPath.section == 0{
            headerView.configureHeader(text: "Audience Metrics")
        }else{
            headerView.configureHeader(text: "Audience Demographic")
        }
        
        return headerView
    }
}


func generateAnalysisLayout() -> UICollectionViewLayout{
    
    
    /*
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))

    // create the item
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7)

    // create the group
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .estimated(115))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)

    //create the section
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuous
    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom:10, trailing: 20)
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    
    return layout
     */
    
    
    
    let layout = UICollectionViewCompositionalLayout {
        section, env in
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
        
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
        
        
        if section == 0 {
            print("Inside section == 0")
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))

            // create the item
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7)

            // create the group
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .estimated(115))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)

            //create the section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom:10, trailing: 20)
            
            section.boundarySupplementaryItems = [headerItem]
            
            return section
        }else{
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))

            // create the item
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7)

            // create the group
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)

            //create the section
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom:10, trailing: 20)
            section.boundarySupplementaryItems = [headerItem]
            return section
        }
    }
    
    return layout
}


