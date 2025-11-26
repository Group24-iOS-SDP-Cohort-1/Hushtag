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
    let analysisResponse = youtubeResponse()
    var scheduleResponse = PostResponse()
    var analysis: [Analysis] = []
    var schedule: [Post] = []
    var ideas: [Idea] = []
    var selectedIndexPath: IndexPath?
    var selectedIdeas: Idea?
    var selectedVideos: Analysis?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        // fetch the data
        
        ideas = ideaResponse.ideas
        analysis = analysisResponse.youtube
        schedule = scheduleResponse.posts
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
            
    }
    func registerCell() {
        collectionView.register(
            UINib (
                nibName: "AnalysisCollectionViewCell",
                bundle: nil
                 ),
            forCellWithReuseIdentifier: "analysis_cell"
        )
        
        collectionView.register(
            UINib(nibName: "ScheduleCollectionViewCell",
                  bundle: nil
                 ),
            forCellWithReuseIdentifier: "schedule_cell")
        
        collectionView.register(
            UINib(nibName: "IdeaCollectionViewCell",
                  bundle: nil
                 ),
            forCellWithReuseIdentifier: "ideas_cell")
        
        collectionView.register(
            UINib(nibName: "HeaderView",
                  bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "headerCell")


    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            section, env in
            
            //define the size of the header view
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
            
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
            
            if section == 0 {
                
                // set the item size
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
            }
            else if section == 1 {
                // set the item size
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                
                // create the item
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7)
                
                // create the group
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .estimated(150))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                
                //create the section
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                section.boundarySupplementaryItems = [headerItem]
    
                return section
            }
            
            // set the item size
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            
            // create the item
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // create the group
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(210))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 1)
            group.interItemSpacing = .fixed(15)
            
            //create the section
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 15
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom:10, trailing: 20)
            section.boundarySupplementaryItems = [headerItem]
            
            return section
        }
        return layout
    }
    
}

extension Overview: UICollectionViewDataSource, UICollectionViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = selectedIndexPath else { return }

            if segue.identifier == "goToAnalysis" {
                let vc = segue.destination as! YoutubeAnalysis
                vc.analysis = selectedVideos

            }

            if segue.identifier == "goToIdea" {
                let nav = segue.destination as! UINavigationController
                let vc = nav.topViewController as! ViewIdea
                vc.ideas = selectedIdeas
                vc.ideas = selectedIdeas
            }

    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        switch indexPath.section {
            case 0:
                performSegue(withIdentifier: "goToAnalysis", sender: nil)

            case 1:
                performSegue(withIdentifier: "goToAnalysis", sender: nil)

            case 2:
                selectedIdeas = ideas[indexPath.row]
                performSegue(withIdentifier: "goToIdea", sender: nil)

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
            return analysis.count
        } else if (section == 1) {
            return schedule.count
        }
        return ideas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "analysis_cell", for: indexPath) as! AnalysisCollectionViewCell
            let analysis = analysis[indexPath.row]
            if indexPath.row == 0 {
                cell.configureCell(analysis: analysis, category: "Youtube")
            } else if indexPath.row == 1 {
                cell.configureCell(analysis: analysis, category: "Instagram")
            } else {
                cell.configureCell(analysis: analysis, category: "FaceBook")
            }
            cell.contentView.layer.cornerRadius = 12
            cell.contentView.layer.masksToBounds = true
            cell.layer.cornerRadius = 12
            cell.layer.masksToBounds = false
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOpacity = 0.1
            cell.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.layer.shadowRadius = 8
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .white

            return cell
        }
        else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "schedule_cell", for: indexPath) as! ScheduleCollectionViewCell
            let schedule = schedule[indexPath.row]
            cell.configureCell(schedule: schedule)
            cell.contentView.layer.cornerRadius = 12
            cell.contentView.layer.masksToBounds = true
            cell.layer.cornerRadius = 12
            cell.layer.masksToBounds = false
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOpacity = 0.10
            cell.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.layer.shadowRadius = 8
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .white
            
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ideas_cell", for: indexPath) as! IdeaCollectionViewCell
        let ideas = ideas[indexPath.row]
        cell.configureCell(ideas: ideas)
        cell.contentView.layer.cornerRadius = 12
        cell.contentView.layer.masksToBounds = true
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.15
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 8
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .white
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // create the header view
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: "headerCell", for: indexPath) as! HeaderView
        if indexPath.section == 0 {
            headerView.configureHeader(text: "Engagement Rates")
        }
        else if indexPath.section == 1 {
            headerView.configureHeader(text: "Upcoming Schedule")
        } else {
            headerView.configureHeader(text: "Suggested for you")
        }
        return headerView
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
