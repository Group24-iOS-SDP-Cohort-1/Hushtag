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
        analysisCollectionView.register(
            UINib(nibName: "LatestContentPerformanceCell", bundle: nil),
            forCellWithReuseIdentifier: "latest_content_performance_cell"
        )
        analysisCollectionView.register(
            UINib(nibName: "TopContentCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "top_content_cell"
        )

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
        
        analysisCollectionView.register(
            UINib(nibName: "OptimalTimeChartCell", bundle: nil),
            forCellWithReuseIdentifier: "optimal_time_cell"
        )
        
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
        return 5
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        switch section {
        case 0:
            return analysisData?.audienceGrid.count ?? 0   // Audience Metrics
        case 1:
            return 1                                       // Latest Content Performance
        case 2:
            return analysisData?.topContent.count ?? 0     // Top Content
        case 3:
            return 1                                       // Audience Demographic
        case 4:
            return 1                                       // Optimal Upload Times
        default:
            return 0
        }
    }
    
    
    
//    func collectionView(
//        _ collectionView: UICollectionView,
//        cellForItemAt indexPath: IndexPath
//    ) -> UICollectionViewCell {
//
//        // SECTION 1 – Audience Demographics (Gender chart)
//        if indexPath.section == 1 {
//            let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: "gender_analysis_cell",
//                for: indexPath
//            ) as! AudienceChartCell
//
//            if let data = analysisData {
//                cell.configure(with: data)
//            }
//            return cell
//        }
//
//        // SECTION 2 – Optimal Upload Time
//        if indexPath.section == 2 {
//            let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: "optimal_time_cell",
//                for: indexPath
//            ) as! OptimalTimeChartCell
//
//            if let data = analysisData {
//                cell.configure(with: data.optimalTime)
//            }
//            return cell
//        }
//
//        // SECTION 0 – Audience Metrics Cards (4 cards)
//        let cell = collectionView.dequeueReusableCell(
//            withReuseIdentifier: "analysis_page_cell",
//            for: indexPath
//        ) as! AnalysisCell
//
//        guard let metric = analysisData?.audienceGrid[indexPath.row] else {
//            return cell
//        }
//
////        cell.configureCell(
////            value: metric.value,
////            type: metric.title
////            // If you added change-based arrows later:
////            // change: metric.change
////        )
//        cell.configureCell(
//            value: metric.value,
//            type: metric.title,
//            change: metric.change
//        )
//
//        return cell
//    }
//
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // SECTION 1 — Latest Content Performance
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "latest_content_performance_cell",
                for: indexPath
            ) as! LatestContentPerformanceCell

            if let latest = analysisData?.latestContent {
                cell.configure(with: latest)
            }

            return cell
        }
        // SECTION 1 – Top Content
        if indexPath.section == 2 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "top_content_cell",
                for: indexPath
            ) as! TopContentCollectionViewCell

            if let item = analysisData?.topContent[indexPath.row] {
                cell.configure(with: item)
            }

            return cell
        }

        // SECTION 2 – Audience Demographic
        if indexPath.section == 3 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "gender_analysis_cell",
                for: indexPath
            ) as! AudienceChartCell

            if let data = analysisData {
                cell.configure(with: data)
            }
            return cell
        }

        // SECTION 3 – Optimal Upload Time
        if indexPath.section == 4 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "optimal_time_cell",
                for: indexPath
            ) as! OptimalTimeChartCell

            if let data = analysisData {
                cell.configure(with: data.optimalTime)
            }
            return cell
        }

        // SECTION 0 – Audience Metrics
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "analysis_page_cell",
            for: indexPath
        ) as! AnalysisCell

        if let metric = analysisData?.audienceGrid[indexPath.row] {
            cell.configureCell(
                value: metric.value,
                type: metric.title,
                change: metric.change
            )
        }

        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: "header",
            withReuseIdentifier: "headerCell",
            for: indexPath
        ) as! HeaderView

        switch indexPath.section {
        case 0:
            headerView.configureHeader(text: "Audience Metrics")
        case 1:
            headerView.configureHeader(text: "Latest Content Performance")
        case 2:
            headerView.configureHeader(text: "Top Content")
        case 3:
            headerView.configureHeader(text: "Audience Demographic")
        case 4:
            headerView.configureHeader(text: "Optimal Upload Times")
        default:
            break
        }

        return headerView
    }
}

func makeHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
    let headerSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(50)
    )

    let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: headerSize,
        elementKind: "header",
        alignment: .top
    )

    // THIS is the key alignment fix
    header.contentInsets = NSDirectionalEdgeInsets(
        top: 0,
        leading: 10,
        bottom: 0,
        trailing: 16
    )

    return header
}


func generateAnalysisLayout() -> UICollectionViewLayout {

    let layout = UICollectionViewCompositionalLayout { section, _ in

        // Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )

        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: "header",
            alignment: .top
        )
        
        

        // =========================================================
        // SECTION 0 — Audience Metrics (2×2 grid)
        // =========================================================
        if section == 0 {

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .absolute(110)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 0, leading: 6, bottom: 0, trailing: 6
            )

            let rowSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(122)
            )

            let row = NSCollectionLayoutGroup.horizontal(
                layoutSize: rowSize,
                repeatingSubitem: item,
                count: 2
            )

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(244)
            )

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [row]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0, leading: 8, bottom: 0, trailing: 8
            )
            section.interGroupSpacing = 0
            section.boundarySupplementaryItems = [headerItem]

            return section
        }
        // =========================================================
        // SECTION 1 — Latest Content Performance
        // =========================================================
        else if section == 1 {

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(180)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 10, leading: 16, bottom: 10, trailing: 16
            )

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: itemSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [makeHeaderItem()]

            return section
        }

        // =========================================================
        // SECTION 1 — Top Content (table-style list)
        // =========================================================
        else if section == 2 {

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(90)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 6, leading: 16, bottom: 6, trailing: 16
            )

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(300)
            )

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )

            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.boundarySupplementaryItems = [makeHeaderItem()]

            return sectionLayout
        }

        // =========================================================
        // SECTION 2 — Audience Demographic
        // =========================================================
        else if section == 3 {

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(200)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 10, leading: 20, bottom: 10, trailing: 20
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: itemSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [makeHeaderItem()]

            return section
        }

        // =========================================================
        // SECTION 3 — Optimal Upload Times
        // =========================================================
        else {

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(200)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 10, leading: 20, bottom: 10, trailing: 20
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: itemSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [makeHeaderItem()]

            return section
        }
    }

    return layout
}


