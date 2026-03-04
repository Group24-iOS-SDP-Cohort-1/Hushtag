import UIKit

class AnalysisDataViewController: UIViewController {
    
    var platform: String = ""
    let controller = AudienceController()
    var audienceMetrics: [AudienceMetrics] = []
    var latestContent: [LatestContent] = []
    var topVideos: [TopVideo] = []
    var revenueInsight: [RevenueInsight] = []
    var audienceDemographic: [AudienceDemographic] = []
    var viewerActivity: [ViewerActivity] = []
    
    @IBOutlet weak var analysisCollectionView: UICollectionView!
    @IBOutlet weak var segmentedTimeOutlet: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        Task {
            await loadAudience()
            await loadLatestContent()
            await loadTopVideos()
            await loadRevenueInsights()
            await loadAudienceDemographic()
            await loadViewerActivity()
        }
        
        analysisCollectionView.register(
            UINib(nibName: "LatestContentPerformanceCell", bundle: nil),
            forCellWithReuseIdentifier: "latest_content_performance_cell"
        )
        analysisCollectionView.register(
            UINib(nibName: "TopContentCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "top_content_cell"
        )
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = "\(platform.capitalized) Analysis"
        analysisCollectionView.dataSource = self
        analysisCollectionView.register(
            UINib (
                nibName: "AnalysisCell", bundle: nil),
            forCellWithReuseIdentifier: "analysis_page_cell"
        )
        
        analysisCollectionView.register(
            UINib(nibName: "AudienceChartCell", bundle: nil),
            forCellWithReuseIdentifier: "gender_analysis_cell"
        )
        
        analysisCollectionView.register(
            UINib(nibName: "HeaderView",
                  bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "headerCell")
        
        analysisCollectionView.register(
            UINib(nibName: "OptimalTimeChartCell", bundle: nil),
            forCellWithReuseIdentifier: "optimal_time_cell"
        )
        
        analysisCollectionView.register(
            UINib(nibName: "RevenueSourceCell", bundle: nil),
            forCellWithReuseIdentifier: "revenue_cell"
        )
        
        let grayColor = UIColor.darkGray
        
        segmentedTimeOutlet.selectedSegmentIndex = 0
        
        // Normal (not selected)
        segmentedTimeOutlet.setTitleTextAttributes([
            .foregroundColor: grayColor,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ], for: .normal)
        
        // Selected
        segmentedTimeOutlet.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ], for: .selected)
        
        let layout = generateAnalysisLayout()
        analysisCollectionView.setCollectionViewLayout(layout, animated: true)
        
        loadDataFor(segmentIndex: 0)
    }
    
    //FUNCTION TO LOAD THE DATA FOR THE SELECTED INDEX
    
    func loadDataFor(segmentIndex: Int) {
//        guard
//            let fullAnalysis,
//            segmentIndex < fullAnalysis.count
//        else {
//            print("Data not loaded")
//            return
//        }
        
        analysisCollectionView.reloadData()
    }
    
    func loadAudience() async {
        do {
            audienceMetrics = try await controller.fetchAudienceMetrics()
            print(audienceMetrics)
            
            await MainActor.run {
                self.analysisCollectionView.reloadSections(IndexSet(integer: 0))
            }
            
        } catch {
            print("Error fetching audience:", error)
        }
    }
    
    func loadLatestContent() async {
        do {
            latestContent = try await controller.fetchLatestContent()
            print(latestContent)
            
            await MainActor.run {
                self.analysisCollectionView.reloadSections(IndexSet(integer: 1))
            }
            
        } catch {
            print("Error fetching latest content:", error)
        }
    }
    
    func loadTopVideos() async {
        do {
            topVideos = try await controller.fetchTopVideos()
            print(topVideos)
            
            await MainActor.run {
                self.analysisCollectionView.reloadSections(IndexSet(integer: 2))
            }
            
        } catch {
            print("Error fetching top video:", error)
        }
    }
    
    func loadRevenueInsights() async {
        do {
            revenueInsight = try await controller.fetchRevenueInsight()
            print(revenueInsight)
            
            await MainActor.run {
                self.analysisCollectionView.reloadSections(IndexSet(integer: 3))
            }
            
        } catch {
            print("Error fetching revenue insight:", error)
        }
    }
    
    func loadAudienceDemographic() async {
        do {
            audienceDemographic = try await controller.fetchAudienceDemographic()
            print(audienceDemographic)
            
            await MainActor.run {
                self.analysisCollectionView.reloadSections(IndexSet(integer: 4))
            }
            
        } catch {
            print("Error fetching revenue insight:", error)
        }
    }
    
    func loadViewerActivity() async {
        do {
            viewerActivity = try await controller.fetchViewerActivity()
            print(viewerActivity)
            
            await MainActor.run {
                self.analysisCollectionView.reloadSections(IndexSet(integer: 5))
            }
            
        } catch {
            print("Error fetching viewer activity:", error)
        }
    }
    
    //FUNCTION TO CHANGE DATA WHEN THE SELECTED SEGMENT CHANGES
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        loadDataFor(segmentIndex: sender.selectedSegmentIndex)
    }
    
    func weeklyActivityData() -> [Int] {
        
        var week = Array(repeating: 0, count: 7)
        
        let calendar = Calendar.current
        
        for item in viewerActivity {
            
            let weekday =
            calendar.component(.weekday, from: item.day) - 1
            
            week[weekday] += item.views
        }
        
        return week
    }
}

extension AnalysisDataViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 6
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 3
        case 1:
            return 1
        case 2:
            return 3
        case 3:
            return 4
        case 4:
            return 1
        case 5:
            return 1
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // SECTION 1 — Latest Content Performance
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "latest_content_performance_cell",
                for: indexPath
            ) as! LatestContentPerformanceCell
            
            guard let latest = latestContent.first else {
                return cell
            }
            cell.configure(with: latest)
            return cell
        }
        // SECTION 1 – Top Content
        if indexPath.section == 2 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "top_content_cell",
                for: indexPath
            ) as! TopContentCollectionViewCell
            
            guard topVideos.indices.contains(indexPath.row) else {
                return cell
            }
            
            let video = topVideos[indexPath.row]
            cell.configure(with: video)
            
            return cell
        }
        
        if indexPath.section == 3 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "revenue_cell",
                for: indexPath
            ) as! RevenueSourceCell
            guard let latest = revenueInsight.first else {
                return cell
            }
            switch indexPath.row {
                
            case 0:
                cell.configure(metric: .ads, data: latest.estimated_ad_revenue)
                
            case 1:
                cell.configure(metric: .paidContent, data: latest.gross_revenue)
                
            case 2:
                cell.configure(metric: .ypp, data: latest.ypp_revenue)
                
            case 3:
                cell.configure(metric: .collaboration, data: 20.00)
                
                
            default:
                break
            }
            return cell
        }
        
        // SECTION 2 – Audience Demographic
        if indexPath.section == 4 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "gender_analysis_cell",
                for: indexPath
            ) as! AudienceChartCell
            
            guard let latest = audienceDemographic.first else {
                return cell
            }
            cell.configure(with: latest)
            return cell
        }
        
        // SECTION 3 – Optimal Upload Time
        if indexPath.section == 5 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "optimal_time_cell",
                for: indexPath
            ) as! OptimalTimeChartCell
            
            cell.configure(with: viewerActivity)
            return cell
        }
        
        // SECTION 0 – Audience Metrics
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "analysis_page_cell",
            for: indexPath
        ) as! AnalysisCell
        
        guard let latest = audienceMetrics.first else {
            return cell
        }
        
        switch indexPath.row {
            
        case 0:
            cell.configure(metric: .views, data: latest.views)
            
        case 1:
            cell.configure(metric: .likes, data: latest.likes)
            
        case 2:
            cell.configure(metric: .watchTime, data: latest.estimated_minutes_watched)
            
        default:
            break
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: "header",
            withReuseIdentifier: "headerCell",
            for: indexPath
        ) as! HeaderView
        
        switch indexPath.section {
        case 0:
            headerView.configureHeader(text: "Audience Metrics")
        case 1:
            headerView.configureHeader(text: "Latest Content Performance")
        case 2:
            headerView.configureHeader(text: "Top Content")
        case 3:
            headerView.configureHeader(text: "Revenue Insights")
        case 4:
            headerView.configureHeader(text: "Audience Demographic")
        case 5:
            headerView.configureHeader(text: "Optimal Upload Times")
        default:
            break
        }
        
        return headerView
    }
}

func makeHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
    let headerSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(50)
    )
    
    let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: headerSize,
        elementKind: "header",
        alignment: .top
    )
    
    // THIS is the key alignment fix
    header.contentInsets = NSDirectionalEdgeInsets(
        top: 0,
        leading: 10,
        bottom: 0,
        trailing: 16
    )
    
    return header
}


func generateAnalysisLayout() -> UICollectionViewLayout {
    
    let layout = UICollectionViewCompositionalLayout { section, _ in
        
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
        
        
        if section == 0 {
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .absolute(110)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 0, leading: 6, bottom: 0, trailing: 6
            )
            
            let rowSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(122)
            )
            
            let row = NSCollectionLayoutGroup.horizontal(
                layoutSize: rowSize,
                repeatingSubitem: item,
                count: 2
            )
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(244)
            )
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [row]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0, leading: 8, bottom: 0, trailing: 8
            )
            section.interGroupSpacing = 0
            section.boundarySupplementaryItems = [headerItem]
            
            return section
        }
        
        else if section == 3 {
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 5, leading: 5, bottom: 5, trailing: 5
            )
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(75)
            )
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                repeatingSubitem: item,
                count: 1
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0, leading: 8, bottom: 0, trailing: 8
            )
            section.interGroupSpacing = 0
            section.boundarySupplementaryItems = [headerItem]
            
            return section
        }
        
        else if section == 1 {
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(180)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 10, leading: 16, bottom: 10, trailing: 16
            )
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: itemSize,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [makeHeaderItem()]
            
            return section
        }
        
        else if section == 2 {
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(90)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 6, leading: 16, bottom: 6, trailing: 16
            )
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(300)
            )
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.boundarySupplementaryItems = [makeHeaderItem()]
            
            return sectionLayout
        }
        
        else if section == 4 {
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(200)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 10, leading: 20, bottom: 10, trailing: 20
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: itemSize,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [makeHeaderItem()]
            
            return section
        }
        
        else {
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(200)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 10, leading: 20, bottom: 10, trailing: 20
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: itemSize,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [makeHeaderItem()]
            
            return section
        }
    }
    return layout
}


