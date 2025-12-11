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
    let ytResponse = youtubeResponse()
    let igResponse = instagramResponse()
    let fbResponse = facebookResponse()
    var postresponse = PostResponse()
    var taskresponse = TaskResponse()
    var dealsresponse = DealResponse()
    var analysis: [Analysis] = []
    var post: [Post] = []
    var task: [Task] = []
    var deal: [Deal] = []
    var ideas: [Idea] = []
    var selectedIndexPath: IndexPath?
    var selectedIdeas: Idea?
    var selectedVideos: Analysis?
    var selectedPost: Post?
    var selectedDeal: Deal?
    var selectedTask: Task?
    var filteredIdeas: [Idea] {
        return ideas.filter { $0.liked == false }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        // fetch the data
        
        ideas = ideaResponse.ideas
        post = postresponse.posts
        task = taskresponse.tasks
        deal = dealsresponse.deals
        analysis = [ytResponse.youtube.first, igResponse.instagram.first, fbResponse.facebook.first].compactMap { $0 }
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
        
        collectionView.register(
            UINib(nibName: "HeaderChevronView",
                  bundle: nil),
            forSupplementaryViewOfKind: "headerChevron",
            withReuseIdentifier: "header_chevron")
        
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
            
            let headerChevron = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "headerChevron", alignment: .top)
            
            let headerButton = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "headerButton", alignment: .top)

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
                section.boundarySupplementaryItems = [headerButton]

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
                section.boundarySupplementaryItems = [headerChevron]
    
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
    
    func applyFilter(_ filter: String) {
        
        switch filter {
        case "week":
            print("Showing past week analysis")
            self.analysis = [
                ytResponse.youtube.first,
                igResponse.instagram.first,
                fbResponse.facebook.first
            ].compactMap { $0 }

        case "month":
            print("Showing past month analysis")
            self.analysis = [
                ytResponse.youtube[1],
                igResponse.instagram[1],
                fbResponse.facebook[1]
            ].compactMap { $0 }

        case "3weeks":
            print("Showing past 3 weeks analysis")
            self.analysis = [
                ytResponse.youtube[2],
                igResponse.instagram[2],
                fbResponse.facebook[2]
            ].compactMap { $0 }

        default:
            break
        }

        // Reload only section 0
        collectionView.reloadSections(IndexSet(integer: 0))
    }
    
}

extension Overview: UICollectionViewDataSource, UICollectionViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = selectedIndexPath else { return }
        
        if segue.identifier == "goToAnalysis" {
            let vc = segue.destination as! AnalysisDataViewController
            //vc.analysis = selectedVideos
        }
        
        if segue.identifier == "goToSchedule" {
            let vc = segue.destination as! Schedule
            vc.posts = post
            vc.deals = deal
            vc.tasks = task
        }
        
        if segue.identifier == "goToDetails" {
            let vc = segue.destination as! Details
            vc.post = selectedPost
        }
        if segue.identifier == "goToIdea" {
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! ViewIdea
            vc.idea = selectedIdeas
            vc.onLikeStatusChanged = { [weak self] updatedIdea in
                guard let self = self else { return }

                // 1. Find the index of this idea
                if let index = self.ideas.firstIndex(where: { $0.id == updatedIdea.id }) {
                    self.ideas[index] = updatedIdea
                }

                // 2. Reload ONLY the ideas section (section 2)
                let ideasSection = IndexSet(integer: 2)
                self.collectionView.reloadSections(ideasSection)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        switch indexPath.section {
            case 0:
                performSegue(withIdentifier: "goToAnalysis", sender: nil)
            case 1:
                selectedPost = post[indexPath.row]
                performSegue(withIdentifier: "goToDetails", sender: nil)
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
            return post.count
        }
        return filteredIdeas.count
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
                cell.configureCell(analysis: analysis, category: "Facebook")
            }

            return cell
        }
        else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "schedule_cell", for: indexPath) as! ScheduleCollectionViewCell
            let schedule = post[indexPath.row]
            cell.configureCell(schedule: schedule)
            
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ideas_cell", for: indexPath) as! IdeaCollectionViewCell
        let idea = filteredIdeas[indexPath.row]
        cell.configureCell(ideas: idea)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == "header" {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: "header",
                withReuseIdentifier: "headerCell",
                for: indexPath
            ) as! HeaderView
            headerView.configureHeader(text: "Suggested for you")
            return headerView
        }

        if kind == "headerChevron" {
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

        
        if kind == "headerButton" {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: "headerButton",
                withReuseIdentifier: "header_button",
                for: indexPath
            ) as! HeaderButton

            headerView.configure()
            
            // Listen to filter selection
            headerView.onFilterSelected = { filter in
                self.applyFilter(filter)
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
