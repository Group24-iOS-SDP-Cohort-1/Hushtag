import UIKit

class InsightsViewController: UIViewController {
    
    @IBOutlet weak var insightIdeaView: UICollectionView!
    var ideas: [Idea] = []
    var selectedIdea: Idea?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        insightIdeaView.delegate = self
        insightIdeaView.dataSource = self
        insightIdeaView.register(UINib(nibName: "IdeaCells", bundle: nil), forCellWithReuseIdentifier: "ideaCell")
        insightIdeaView.setCollectionViewLayout(generateLayout(), animated: true)
        Task {
            OpaqueLoadingScreen.shared.show(message: "Fetching Ideas")
            await SessionManager.shared.restoreSession()
            
            await MainActor.run {
                self.ideas = SessionManager.shared.personalizedIdeas
                self.insightIdeaView.reloadData()
            }
            OpaqueLoadingScreen.shared.hide()
        }
    }
    
    func generateLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, env in
            
            
            // self-sizing item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(116)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: itemSize,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 10, leading: 0, bottom: 10, trailing: 0
            )
            section.interGroupSpacing = 15
            
            return section
        }
        return layout
    }
}

extension InsightsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ideas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ideaCell", for: indexPath) as! IdeaCells
        cell.configure(idea: ideas[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedIdea = ideas[indexPath.row]
        
        let storyboard = UIStoryboard(name: "ViewIdea", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IdeaVC") as! ViewIdea
        
        vc.idea = selectedIdea
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
