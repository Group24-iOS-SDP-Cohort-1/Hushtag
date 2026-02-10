//
//  ViewIdea.swift
//  Hushtag
//
//  Created by SDC-USER on 25/11/25.
//

import UIKit
import SwiftUI
import SafariServices
import Charts



class ViewIdea: UIViewController {
    
    @IBOutlet weak var videoView: UICollectionView!
    @IBOutlet weak var hashtagLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var descriptionStack: UIStackView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var graphView: UIView!

    @IBOutlet weak var draftScript: UIButton!

    @IBOutlet weak var stackView: UIStackView!
    private var isChecked: Bool = false
    private var chartHostingController: UIHostingController<EngagementLineChart>?
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
            titleLabel.numberOfLines = 0
            descriptionLabel.text = idea.description
            descriptionLabel.numberOfLines = 10
            hashtagLabel.text = "#" + idea.hashtag.joined(separator: " #")
            video = idea.videos ?? []

            isChecked = idea.liked ?? false
            likeButton.image = UIImage(systemName: isChecked ? "heart.fill" : "heart")
        }
      //  scrollView.alwaysBounceHorizontal = false
        videoView.isScrollEnabled = false

        setupEngagementChart()
        videoView.setCollectionViewLayout(generateLayout(), animated: true)
//        scrollView.contentSize.width = stackView.frame.width
//        scrollView.contentSize.height = stackView.frame.origin.y + stackView.frame.height + 200
        print("Scroll frame height:", scrollView.frame.height)
           print("Content height:", scrollView.contentLayoutGuide.layoutFrame.height)
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
        chatVC.autoSendMessage = "script"
        navigationController?.pushViewController(chatVC, animated: true)
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

        return UICollectionViewCompositionalLayout { sectionIndex, _ in

            // Only section 0 has horizontal scrolling
            guard sectionIndex == 0 else {
                return nil
            }

            // Header
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(50)
            )

            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: "header",
                alignment: .top
            )

            // Item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(150)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 7,
                bottom: 0,
                trailing: 7
            )

            // Group
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.75),
                heightDimension: .estimated(150)
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )

            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = [headerItem]

            return section
        }
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

        // Update chart with selected video
        updateEngagementChart(for: selectedVideo)

        guard let url = URL(string: selectedVideo.link) else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }

    func setupEngagementChart() {
        guard !video.isEmpty else {
            print("No videos available")
            return
        }

        let chartView = EngagementLineChart(data: video)

        let hostingVC = UIHostingController(rootView: chartView)
        hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
        hostingVC.view.backgroundColor = .clear

        addChild(hostingVC)
        graphView.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)

        NSLayoutConstraint.activate([
            hostingVC.view.heightAnchor.constraint(equalToConstant: 240)
        ])

        chartHostingController = hostingVC
    }

    func updateEngagementChart(for video: Video) {
        chartHostingController?.rootView = EngagementLineChart(data: [video])
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
