import UIKit
import SwiftUI
import Charts

class ViewIdea: UIViewController {
    
    @IBOutlet weak var ideaView: UICollectionView!
    
    var idea: Idea?
    var video: [Video] = []
    var ideaId: UUID?
    var hasExistingScript: Bool = false
    var ideaMilestone: Int = 0
    var completedScriptTypes: Set<String> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        ideaView.delegate = self
        ideaView.dataSource = self
        ideaView.setCollectionViewLayout(generateLayout(), animated: true)
        if idea == nil, let ideaId = ideaId {
            self.idea = SessionManager.shared.personalizedIdeas.first(where: { $0.id == ideaId })
        }
}
    func checkForExistingScript() {
        guard let idea = idea else { return }
        Task {
            do {
                let script = try await ScriptedIdeasController().fetchScriptByIdeaId(ideaId: idea.id)

                DispatchQueue.main.async {
                    self.hasExistingScript = script != nil

                    if let script = script {
                        var types: Set<String> = []
                        if let s = script.script, !s.isEmpty { types.insert("script") }
                        if let t = script.title, !t.isEmpty { types.insert("title") }
                        if let d = script.description, !d.isEmpty { types.insert("description") }
                        self.completedScriptTypes = types
                        self.ideaMilestone = types.count
                    } else {
                        self.completedScriptTypes = []
                        self.ideaMilestone = 0
                    }

                    self.ideaView.reloadSections(IndexSet(integer: 0))
                }
            } catch {
                print("Failed to fetch script:", error)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForExistingScript()
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
            chatVC.ideaId = idea.id
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

    func handleDraftScriptTap(for idea: Idea) {
        Task {
            do {
                let existing = try await ScriptedIdeasController()
                    .fetchScriptByIdeaId(ideaId: idea.id)

                DispatchQueue.main.async {
                    if let existingScript = existing {
                        // Script exists — go straight to it
                        let storyboard = UIStoryboard(name: "Ideate", bundle: nil)
                        guard let vc = storyboard.instantiateViewController(
                            withIdentifier: "scriptedIdea"
                        ) as? ScriptedIdeas else { return }
                        vc.idea = existingScript
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        // No script yet — go to chatbot
                        self.didTapDraftScript(for: idea)
                    }
                }
            } catch {
                // Fallback to chatbot if fetch fails
                DispatchQueue.main.async { self.didTapDraftScript(for: idea) }
            }
        }
    }

    func registerCell() {
        
        ideaView.register(
            UINib(nibName: "HeaderView",
                  bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "headerCell");

        ideaView.register(
            UINib(nibName: "IdeaProgressCollectionViewCell", bundle: nil), 
            forCellWithReuseIdentifier: "cell"
        )

    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            section, env in
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
            
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
          if section == 0 {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(140)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: itemSize,
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 8, leading: 20, bottom: 15, trailing: 20
                )
                return section
            }
            if section == 1 {

                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(100)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
              
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(100)
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 20,
                    bottom: 0,
                    trailing: 20
                )
                
                
                return section
            }
            
            else if section == 2 {

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
            
            else if section == 3 {

                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(70)
                )

                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: itemSize,
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)

                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 20,
                    bottom: 0,
                    trailing: 20
                )

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
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 2 {
            return 2
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 0 {
            let cell = ideaView.dequeueReusableCell(
                withReuseIdentifier: "cell",
                for: indexPath
            ) as! IdeaProgressCollectionViewCell

            let completedTypes = Set(
                [("script", ideaMilestone >= 1), ("title", ideaMilestone >= 2), ("description", ideaMilestone >= 3)]
                    .filter { $0.1 }.map { $0.0 }
            )
            cell.configure(
                completedTypes: completedScriptTypes,
                buttonTitle: hasExistingScript ? "View Draft" : "Draft Script"
            )
            cell.onButtonTapped = { [weak self] in
                guard let self = self, let idea = self.idea else { return }
                self.handleDraftScriptTap(for: idea)
            }
            return cell
        }
        else if indexPath.section == 1 {
            let cell = ideaView.dequeueReusableCell(withReuseIdentifier: "basicInfo", for: indexPath) as! IdeaDetailsCollectionViewCell
            if let idea = idea {
                cell.configure(with: idea)
            }
            cell.onContentUpdated = { [weak self] in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.ideaView.performBatchUpdates(nil) 
                }
            }
            
            return cell
        }
        
        else if indexPath.section == 2 {
            let cell = ideaView.dequeueReusableCell(withReuseIdentifier: "statistics", for: indexPath) as! IdeaDetailsCollectionViewCell
            
            guard let idea = idea else { return cell }

                // Use your existing stats function
                let values = statistics(with: idea)

                // Safe guard
                guard indexPath.row < values.count else { return cell }

                // Labels match values
                let symbols = ["eye", "hand.thumbsup"]

                let value = values[indexPath.row]
                let symbol = symbols[indexPath.row]

                cell.configureStatistic(value, symbol)
                cell.view.layer.cornerRadius = 16
                cell.view.layer.borderWidth = 0.5
                cell.view.backgroundColor = UIColor.accent.withAlphaComponent(0.1)
                cell.view.layer.borderColor = UIColor.accent.withAlphaComponent(1.0).cgColor
            return cell
        } else if indexPath.section == 3 {
            let cell = ideaView.dequeueReusableCell(withReuseIdentifier: "gaps", for: indexPath) as! IdeaDetailsCollectionViewCell
            
            cell.configureHashtag(idea?.hashtags ?? [])
            return cell
        }



        let cell = ideaView.dequeueReusableCell(withReuseIdentifier: "button", for: indexPath) as! IdeaDetailsCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == "header", indexPath.section == 2 {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: "header",
                withReuseIdentifier: "headerCell",
                for: indexPath
            ) as! HeaderView
            
            headerView.configureHeader(text: "Performance Statistics")
            return headerView
        }
        else if kind == "header", indexPath.section == 3 {
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
