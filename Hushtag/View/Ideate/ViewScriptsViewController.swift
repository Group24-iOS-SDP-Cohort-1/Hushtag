//
//  ViewScriptsViewController.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class ViewScriptsViewController: UIViewController {

    
    var pageTitle: String = "" // Default value
    var cellReuseIdentifier: String = "allScriptsCell"
    
    var ideaResponse = IdeaResponse()
    var ideas: [Idea] = []
    var isSearchMode = false
    var likedIdeas: [Idea] = []

    @IBOutlet weak var scriptsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        ideas = ideaResponse.ideas
        likedIdeas = ideas.filter { LikedIds.likedIdeaIds.contains($0.id) }

        navigationItem.title = pageTitle
        
        //ideas = ideaResponse.ideas
        
        scriptsCollectionView.dataSource = self
        scriptsCollectionView.delegate = self
        
        scriptsCollectionView.register(UINib(nibName: "likedCells", bundle: nil), forCellWithReuseIdentifier: "likedCells")
        scriptsCollectionView.register(UINib(nibName: "LikedCellsNew", bundle: nil), forCellWithReuseIdentifier: "likedCellsNew")
        
        let layout = generateScriptsLayout(title: pageTitle)
        scriptsCollectionView.setCollectionViewLayout(layout, animated: true)
        //scriptsCollectionView.clipsToBounds = false
        
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toScriptedIdeas",
//           let destinationVC = segue.destination as? ScriptedIdeas,
//           let idea = sender as? Idea {
//            destinationVC.idea = idea
//        }
//    }

}

extension ViewScriptsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if pageTitle == "Your Scripts"{
            return ideas.count
        }else{
            return likedIdeas.count
        }
        
        //return ideas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if pageTitle == "Your Scripts"{
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "allScriptsCell",
                for: indexPath
            ) as! ViewAllScriptsCell

            let idea = ideas[indexPath.row]
            cell.configureCell(idea: idea)
            return cell
        }
        
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "likedCellsNew",
            for: indexPath
        ) as! LikedCellsNew

        let idea = likedIdeas[indexPath.row]
        cell.configureCell(idea: idea)
        return cell
    }
    
    
}

func generateScriptsLayout(title: String) -> UICollectionViewLayout{
    //LAYOUT FOR VIEWING ALL SCRIPTS
    if title == "Your Scripts"{
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(160)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        //group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 15
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10, leading: 10, bottom: 10, trailing: 10
        )
        
        let layout = UICollectionViewCompositionalLayout(section: section)
            
        print("Your Scripts")
        
        return layout
    }
    
    //LAYOUT FOR VIEWING ALL LIKED IDEAS
    
    let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalHeight(1.0)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

    let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(130)
    )
    let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: groupSize,
        subitems: [item]
    )
    //group.interItemSpacing = .fixed(10)

    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 15
    section.contentInsets = NSDirectionalEdgeInsets(
        top: 10, leading: 10, bottom: 10, trailing: 10
    )

    let layout = UICollectionViewCompositionalLayout(section: section)
        
    print("Liked ideas")
    
    return layout
    
}



extension ViewScriptsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {


        if pageTitle == "Your Scripts"{
            
            let idea = ideas[indexPath.row]
            let storyboard = UIStoryboard(name: "Ideate", bundle: nil)
            if let destinationVC = storyboard.instantiateViewController(withIdentifier: "scriptedIdea") as? ScriptedIdeas {
                destinationVC.idea = idea
                    
                // 3. Push the view controller
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
            
            return
        }
        
        let idea = ideas[indexPath.row]
        let storyboard = UIStoryboard(name: "Ideate", bundle: nil)
        if let destinationVC = storyboard.instantiateViewController(withIdentifier: "scriptedIdea") as? ScriptedIdeas {
            destinationVC.idea = idea
                
            // 3. Push the view controller
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
        
    }
    
}
