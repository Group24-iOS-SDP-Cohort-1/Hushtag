//
//  ViewScriptsViewController.swift
//  Hushtag
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class ViewScriptsViewController: UIViewController {
    var ideaResponse = IdeaResponse()
    var ideas: [Idea] = []

    var pageTitle: String = "" 
    var cellReuseIdentifier: String = "allScriptsCell"

    var isSearchMode = false
    var likedIdeas: [Idea] = []
    var myScripts: [ScriptedIdea] = []
    
    private let scriptsController = ScriptedIdeasController()

    @IBOutlet weak var scriptsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //        ideas = ideaResponse.ideas
        //        likedIdeas = ideas.filter { LikedIds.likedIdeaIds.contains($0.id) }
        navigationItem.title = pageTitle
        scriptsCollectionView.dataSource = self
        scriptsCollectionView.delegate = self
        
        scriptsCollectionView.register(UINib(nibName: "ScriptsCell1", bundle: nil), forCellWithReuseIdentifier: "scriptedIdeas")
        scriptsCollectionView.register(UINib(nibName: "LikedCellsNew", bundle: nil), forCellWithReuseIdentifier: "likedCellsNew")
        
        
        let layout = generateScriptsLayout(title: pageTitle)
        scriptsCollectionView.setCollectionViewLayout(layout, animated: true)
        
        if pageTitle == "Your Scripts" {
            // 1. Fetch from Supabase
            fetchMyScripts()
        } else {
            // 2. Load Liked Ideas (Existing Logic)
            ideas = ideaResponse.ideas
            likedIdeas = ideas.filter { LikedIds.likedIdeaIds.contains($0.id) }
            NotificationCenter.default.addObserver(self, selector: #selector(syncLikedIdeas), name: .didUpdateLikedStatus, object: nil)
            updateEmptyState()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // Refresh the list every time the view appears
            if pageTitle == "Your Scripts" {
                fetchMyScripts()
            }
        }
    
    
    func fetchMyScripts() {
            // Show a loading indicator here if you like
            Task {
                do {
                    // Fetch using your new controller
                    let scripts = try await scriptsController.fetchScripts()
                    
                    await MainActor.run {
                        self.myScripts = scripts
                        self.scriptsCollectionView.reloadData()
                        self.updateEmptyState()
                    }
                } catch {
                    print("Error fetching scripts: \(error)")
                    // Handle error (e.g., show alert)
                }
            }
        }
    
    
    @objc func syncLikedIdeas() {
        likedIdeas = ideas.filter { LikedIds.likedIdeaIds.contains($0.id) }
        scriptsCollectionView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
            
            // Separate Empty State logic for "Your Scripts"
            if pageTitle == "Your Scripts" {
                if myScripts.isEmpty {
                    showEmptyView(message: "No scripts yet", iconName: "doc.text")
                    scriptsCollectionView.backgroundView?.isHidden = false
                } else {
                    scriptsCollectionView.backgroundView = nil
                }
                return
            }

            // Logic for "Liked Ideas"
            if likedIdeas.isEmpty {
                showEmptyView(message: "No liked ideas", iconName: "heart.slash")
                scriptsCollectionView.backgroundView?.isHidden = false
            } else {
                scriptsCollectionView.backgroundView = nil
            }
        }
        
        // Helper to draw empty view
        private func showEmptyView(message: String, iconName: String) {
            let emptyView = UIView(frame: scriptsCollectionView.bounds)

            let imageView = UIImageView(image: UIImage(systemName: iconName))
            imageView.tintColor = .tertiaryLabel
            imageView.heightAnchor.constraint(equalToConstant: 38).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 38).isActive = true

            let label = UILabel()
            label.text = message
            label.textColor = .secondaryLabel
            label.font = .systemFont(ofSize: 22, weight: .medium)
            label.textAlignment = .center

            let stack = UIStackView(arrangedSubviews: [imageView, label])
            stack.axis = .vertical
            stack.spacing = 12
            stack.alignment = .center

            emptyView.addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                stack.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
                stack.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor)
            ])

            scriptsCollectionView.backgroundView = emptyView
        }

}

extension ViewScriptsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if pageTitle == "Your Scripts"{
            return myScripts.count
        }else{
            return likedIdeas.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if pageTitle == "Your Scripts"{
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "scriptedIdeas",
                for: indexPath
            ) as! ScriptsCell1

            let script = myScripts[indexPath.row]
            cell.configureCell(with: script)
            return cell
        }

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "likedCellsNew",
            for: indexPath
        ) as! LikedCellsNew

        let idea = likedIdeas[indexPath.row]
        cell.configureCell(idea: idea)
        
        cell.delegate = self
        
        cell.onLikeToggle = { [weak self, weak collectionView] in
                guard let self = self else { return }
                if let currentIndex = self.likedIdeas.firstIndex(where: { $0.id == idea.id }) {
                    self.likedIdeas.remove(at: currentIndex)
                    let indexPathToDelete = IndexPath(item: currentIndex, section: 0)
                    collectionView?.performBatchUpdates({
                        collectionView?.deleteItems(at: [indexPathToDelete])
                    }, completion: { _ in
                        self.updateEmptyState()
                    })

                }
            }
        return cell
    }
}

func generateScriptsLayout(title: String) -> UICollectionViewLayout{
    if title == "Your Scripts"{
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(147)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 15
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10, leading: 10, bottom: 10, trailing: 10
        )
        
        let layout = UICollectionViewCompositionalLayout(section: section)
            
        print("Your Scripts")
        
        return layout
    }

    let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(120)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

    let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(170)
    )
    let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: groupSize,
        subitems: [item]
    )

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
            let script = myScripts[indexPath.row]
            let storyboard = UIStoryboard(name: "Ideate", bundle: nil)
            if let destinationVC = storyboard.instantiateViewController(withIdentifier: "scriptedIdea") as? ScriptedIdeas {
                destinationVC.idea = script
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
            return
        }

    }
    
}

extension ViewScriptsViewController: LikedCellDelegate {

    func didTapDraftScript(for idea: Idea) {
        let storyboard = UIStoryboard(name: "Chatbot", bundle: nil)
        guard let chatVC = storyboard.instantiateViewController(
            withIdentifier: "Chatbot"
        ) as? Chatbot else { return }
        chatVC.autoSendMessage = "script"
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
