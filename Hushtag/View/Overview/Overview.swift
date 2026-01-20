//
//  Overview-Main.swift
//  Hushtag
//
//  Created by SDC-USER on 17/11/25.
//

import UIKit
class Overview: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var ideaResponse = IdeaResponse()
    var dataStore: DataStore = DataStore.shared
    
    let analysisResponse = AnalysisResponse()
    var analysis: [Analysis] = []
    var ideas: [Idea] = []
    var selectedIndexPath: IndexPath?
    var selectedScheduleItem: ScheduleItem?

    var activities: [(String, Int, String)] = []
    var lists: [(String, Int)] = []

    var filteredSchedule: [ScheduleItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        
        analysis = analysisResponse.analysis
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        loadSchedule(for: Date())
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
        
        collectionView.register(
            UINib(nibName: "HeaderChevronView",
                  bundle: nil),
            forSupplementaryViewOfKind: "headerChevron",
            withReuseIdentifier: "header_chevron")
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            section, env in
            
            //define the size of the header view
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
            
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
            
            let headerChevron = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "headerChevron", alignment: .top)

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
            section.boundarySupplementaryItems = [headerChevron]

            return section
        }
        return layout
    }

    func loadSchedule(for date: Date) {
        filteredSchedule = dataStore.scheduleItems(on: date)
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
                vc.fullAnalysis = analysis
            }
        }
        if segue.identifier == "goToActivities" {
            guard let row = sender as? Int else { return }
            let vc = segue.destination as! Activities

            vc.scheduleItems = filteredSchedule

            switch row {
            case 0:
                vc.title = "All"
                vc.filter = .all
            case 1:
                vc.title = "Completed"
                vc.filter = .completed
            default:
                break
            }
        }
        if segue.identifier == "goToAddSchedule" {
            let vc = segue.destination as! AddViewController
            vc.delegate = self
        }
        
        if segue.identifier == "goToSchedule" {
            //let nav = segue.destination as! UINavigationController
            let vc = segue.destination as! Schedule
            vc.scheduleItem = filteredSchedule
        }

        if segue.identifier == "goToDetails" {
            let vc = segue.destination as! Details
            vc.schedule = filteredSchedule[indexPath.row]
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: "goToAnalysis", sender: nil)
        case 1:
            if indexPath.row == filteredSchedule.count {
                performSegue(withIdentifier: "goToAddSchedule", sender: self)
            } else {
                selectedScheduleItem = filteredSchedule[indexPath.row]
                performSegue(withIdentifier: "goToDetails", sender: self)
            }

        default:
            break
        }
    }

    
    // to make 2 sections; by default collection view only has 1 section
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if  (section == 0) {
            return 1
        }
        return filteredSchedule.isEmpty ? 1 : filteredSchedule.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "analysis_cell", for: indexPath) as! Analytics
            cell.configure()
            return cell
        }
        else if indexPath.section == 1 {
            
            if indexPath.row == filteredSchedule.count {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "addScheduleCell",
                    for: indexPath
                )
                cell.applyLiquidGlassEffect()
                return cell
            }
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcoming_schedule", for: indexPath) as! ScheduleCollectionViewCell
        
        let item = filteredSchedule[indexPath.row]

        cell.configure(with: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == "headerChevron", indexPath.section == 1 {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: "headerChevron",
                withReuseIdentifier: "header_chevron",
                for: indexPath
            ) as! HeaderChevronView

            headerView.configure(title: "Upcoming Schedule")
            headerView.onTap = { [weak self] in
                self?.performSegue(withIdentifier: "goToSchedule", sender: nil)
            }
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

//extension Overview: AddViewControllerDelegate {
//
//    func addViewController(_ controller: AddViewController, didAddDeal deal: Deal) {
//        dataStore.saveDeal(deal)
//        //refreshTodaySchedule()
//    }
//
//    func addViewController(_ controller: AddViewController, didAddPost post: Post) {
//        dataStore.savePost(post)
//        //refreshTodaySchedule()
//    }
//
////    private func refreshTodaySchedule() {
////        post = dataStore.getPosts()
////        task = dataStore.getTasks()
////        deal = dataStore.getDeals()
////
////        loadSchedule(for: Date())
////
////        collectionView.performBatchUpdates {
////            collectionView.reloadSections(IndexSet(integer: 1))
////        }
////    }
//}
extension Overview: AddViewDelegate {

    func addViewController(_ controller: AddViewController, didCreatePost post: Post) {
        loadSchedule(for: Date())
    }
}
