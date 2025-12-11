//
//  ViewIdea.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit
import SafariServices

class ViewIdea: UIViewController {
    
    @IBOutlet weak var videoView: UICollectionView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var hashtagLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeButton: UIBarButtonItem!
    private var isChecked: Bool = false
    var idea: Idea?
    var video: [Video] = []
    var onLikeStatusChanged: ((Idea) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        videoView.dataSource = self
        videoView.delegate = self


        if let idea = idea {
            titleLabel.text = idea.title
            titleLabel.numberOfLines = 2
            descriptionLabel.text = idea.description
            descriptionLabel.numberOfLines = 0
            hashtagLabel.text = "#" +  idea.hashtag.joined(separator: " #")
            video = idea.videos
            likeButton.image = UIImage(systemName: idea.liked ? "heart.fill" : "heart")
        }
        videoView.setCollectionViewLayout(generateLayout(), animated: true)
    }
    
    func registerCell() {
        videoView.register(
            UINib (
                nibName: "TrendingVideoCollectionViewCell",
                bundle: nil
            ),
            forCellWithReuseIdentifier: "trending_video"
        )
        videoView.register(
            UINib(nibName: "HeaderView",
                  bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "headerCell")
    }
    
    @IBAction func likeButtonPressed(_ sender: UIBarButtonItem) {
        isChecked.toggle()
        let imageName = isChecked ? "heart.fill" : "heart"
        
        likeButton.image = UIImage(systemName: imageName)
        sender.image = UIImage(systemName: imageName)
        idea?.liked = isChecked
        if let updatedIdea = idea {
            onLikeStatusChanged?(updatedIdea)
        }
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            section, env in
            
        //define the size of the header view
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
        
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150))
        
        // create the item
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7)
        
        // create the group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75), heightDimension: .estimated(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        
        //create the section
        let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
//        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        section.boundarySupplementaryItems = [headerItem]

        return section
    }
        return layout
    }
}

extension ViewIdea: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return video.count
        }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trending_video", for: indexPath) as! TrendingVideoCollectionViewCell
        
        let vid = video[indexPath.item]
        
        cell.configureVideo(video: vid)

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // create the header view
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: "headerCell", for: indexPath) as! HeaderView
        headerView.configureHeader(text: "Trending Videos")
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedVideo = video[indexPath.item]

        // Assuming your Video model has a property: video.url or video.link
        guard let url = URL(string: selectedVideo.link) else {
            print("Invalid URL")
            return
        }

        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
//    func extractYouTubeID(from url: String) -> String? {
//        guard let url = URL(string: url) else { return nil }
//        
//        // case: https://youtu.be/VIDEOID?si=XXXX
//        if url.host?.contains("youtu.be") == true {
//            return url.pathComponents.last // strips query automatically
//        }
//        
//        // case: https://www.youtube.com/watch?v=VIDEOID
//        if url.host?.contains("youtube.com") == true {
//            let components = URLComponents(string: url.absoluteString)
//            return components?
//                .queryItems?
//                .first(where: { $0.name == "v" })?
//                .value
//        }
//
//        return nil
//    }
//    func youtubeThumbnailURL(from url: String) -> URL? {
//        guard let id = extractYouTubeID(from: url) else { return nil }
//        return URL(string: "https://img.youtube.com/vi/\(id)/hqdefault.jpg")
//    }

}
