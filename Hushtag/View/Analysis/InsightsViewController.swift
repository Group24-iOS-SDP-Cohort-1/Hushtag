import UIKit

class InsightsViewController: UIViewController {
    
    @IBOutlet weak var insightIdeaView: UICollectionView!
    var ideas: [Idea] = []
    var analyticsIdeas: [AnalyticsIdea] = []
    var selectedIdea: Idea?
    
    var audienceMetrics: AudienceMetrics?
    var latestContent: [LatestContent] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        insightIdeaView.delegate = self
        insightIdeaView.dataSource = self
        insightIdeaView.register(UINib(nibName: "IdeaCells", bundle: nil), forCellWithReuseIdentifier: "ideaCell")
        insightIdeaView.setCollectionViewLayout(generateLayout(), animated: true)
        Task {
            await MainActor.run {
                OpaqueLoadingScreen.shared.show(message: "Generating Video Ideas...")
            }
            
            do {
                let channel = ChannelMetricsPayload(
                    id: SessionManager.shared.currentUser?.uid ?? UUID().uuidString,
                    title: "My Channel",
                    niche: SessionManager.shared.userPreferences?.niche.first?.rawValue ?? "General",
                    subscribers: audienceMetrics?.subscribers ?? 0,
                    postingFrequencyPerWeek: 3,
                    audienceGeo: []
                )
                
                let videos = latestContent.map { video in
                    GroqVideoPayload(
                        title: video.title,
                        views: video.views,
                        likes: video.likes,
                        comments: 0,
                        duration: video.duration_seconds,
                        publishedAt: ISO8601DateFormatter().string(from: video.published_at)
                    )
                }
                
                let payload = YoutubeIdeaGeneratorPayload(
                    analytics: audienceMetrics,
                    videos: videos,
                    channel: channel
                )
                
                let generatedIdeas = try await YouTubeController.shared.generateIdeas(payload: payload)
                
                await MainActor.run {
                    self.analyticsIdeas = generatedIdeas
                    self.insightIdeaView.reloadData()
                }
            } catch {
                print("Failed to generate ideas:", error)
                // Fallback
                await SessionManager.shared.restoreSession()
                
                await MainActor.run {
                    self.ideas = SessionManager.shared.personalizedIdeas
                    self.insightIdeaView.reloadData()
                }
            }
            await MainActor.run {
                OpaqueLoadingScreen.shared.hide()
            }
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
        return analyticsIdeas.isEmpty ? ideas.count : analyticsIdeas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ideaCell", for: indexPath) as! IdeaCells
        if !analyticsIdeas.isEmpty {
            let analyticsIdea = analyticsIdeas[indexPath.row]
            let mockIdea = Idea(id: analyticsIdea.id, ideaKey: nil, title: analyticsIdea.title, description: analyticsIdea.hook, format: analyticsIdea.format, hashtags: [], noveltyScore: Int(analyticsIdea.estimated_virality_score), videos: nil, expandedDescription: nil, liked: false)
            cell.configure(idea: mockIdea)
        } else {
            cell.configure(idea: ideas[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if !analyticsIdeas.isEmpty {
            let selectedIdea = analyticsIdeas[indexPath.row]
            let vc = AnalyticsIdeaDetailViewController()
            vc.analyticsIdea = selectedIdea
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let selectedIdea = ideas[indexPath.row]
            let storyboard = UIStoryboard(name: "ViewIdea", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "IdeaVC") as! ViewIdea
            vc.idea = selectedIdea
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
