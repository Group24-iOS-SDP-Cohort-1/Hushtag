import UIKit
import SwiftUI
import SafariServices
import Charts

class ViewIdea: UIViewController {
    
    @IBOutlet weak var ideaView: UICollectionView!
    
    var idea: Idea?
    var video: [Video] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        ideaView.delegate = self
        ideaView.dataSource = self
        ideaView.setCollectionViewLayout(generateLayout(), animated: true)
    }
    
    
        @IBAction func draftTap(_ sender: Any) {
            guard let idea = idea else { return }
            didTapDraftScript(for: idea)
    
        }
    
        func didTapDraftScript(for idea: Idea) {
            let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)
            guard let chatVC = storyboard.instantiateViewController(
                withIdentifier: "Chatbot"
            ) as? Chatbot else { return }
            chatVC.autoSendMessage = """
    Create a short creator-style script for this video idea:
    
    Title: "\(idea.title)"
    Description: "\(idea.description)"
    
    Structure:
    1. Hook (1 sentence)
    2. What happens (2–3 sentences)
    3. Twist or surprise (1 sentence)
    4. CTA (1 sentence)
    
    Tone: casual, friendly, modern.
    Length: 15–20 seconds.
    """
            navigationController?.pushViewController(chatVC, animated: true)
        }
    
    func registerCell() {
        
        ideaView.register(
            UINib(nibName: "HeaderView",
                  bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "headerCell")
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
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                
                // create the group
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.25))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 7)
                
                //create the section
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
                
                return section
            }
            else if section == 1 {
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                
                // create the item
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                
                // create the group
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .estimated(110))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
                
                //create the section
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
                section.orthogonalScrollingBehavior = .continuous
                section.boundarySupplementaryItems = [headerItem]
                
                return section
            }
            
            else if section == 2 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                
                // create the item
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                
                // create the group
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 7)
                
                //create the section
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
                section.orthogonalScrollingBehavior = .continuous
                section.boundarySupplementaryItems = [headerItem]
                
                return section
            }
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            
            // create the item
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            // create the group
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.25))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 7)
            
            //create the section
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
            
            return section
        }
        return layout
    }
    
    func statistics(with idea: Idea) -> [Int] {
        
        guard let videos = idea.videos, !videos.isEmpty else {
            print("No videos available")
            return []
        }
        
        // Convert totals into Double
        let totalViews = videos.reduce(0) { $0 + $1.views }
        let totalLikes = videos.reduce(0) { $0 + $1.likes }
        
        let count = videos.count
        
        let avgViews = totalViews / count
        let avgLikes = totalLikes / count
        
        return [avgViews, avgLikes]
    }
}

extension ViewIdea: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1 {
            return 2
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = ideaView.dequeueReusableCell(withReuseIdentifier: "basicInfo", for: indexPath) as! IdeaDetailsCollectionViewCell
            if let idea = idea {
                cell.configure(with: idea)
            }
            
            return cell
        }
        
        else if indexPath.section == 1 {
            let cell = ideaView.dequeueReusableCell(withReuseIdentifier: "statistics", for: indexPath) as! IdeaDetailsCollectionViewCell
            
            guard let idea = idea else { return cell }

                // Use your existing stats function
                let values = statistics(with: idea)

                // Safe guard
                guard indexPath.row < values.count else { return cell }

                // Labels match values
                let labels = ["Views", "Likes"]

                let value = values[indexPath.row]
                let label = labels[indexPath.row]

                cell.configureStatistic(value, label)
            return cell
        } else if indexPath.section == 2 {
            let cell = ideaView.dequeueReusableCell(withReuseIdentifier: "gaps", for: indexPath) as! IdeaDetailsCollectionViewCell
            
            cell.configureHashtag(idea?.hashtags ?? [])
            return cell
        }
        let cell = ideaView.dequeueReusableCell(withReuseIdentifier: "button", for: indexPath) as! IdeaDetailsCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == "header", indexPath.section == 1 {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: "header",
                withReuseIdentifier: "headerCell",
                for: indexPath
            ) as! HeaderView
            
            headerView.configureHeader(text: "Performance Statistics")
            return headerView
        }
        else if kind == "header", indexPath.section == 2 {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: "header",
                withReuseIdentifier: "headerCell",
                for: indexPath
            ) as! HeaderView
            
            headerView.configureHeader(text: "Trending Hashtags")
            return headerView
        }
        return UICollectionReusableView()
    }
}
