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
    var shouldShowRevenue: Bool {
        return !revenueInsight.isEmpty
    }
    var startDate: String = ""
    var endDate: String = ""
    
    @IBOutlet weak var analysisCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            endDate = formatter.string(from: Date())
            startDate = formatter.string(
                from: Calendar.current.date(byAdding: .day, value: -30, to: Date())!
            )

        Task {
            await loadAllData()
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
        
        let layout = generateAnalysisLayout()
        analysisCollectionView.setCollectionViewLayout(layout, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "calendar"),
            style: .plain,
            target: self,
            action: #selector(openDatePicker)
        )
    }
    
    @objc func openDatePicker() {

        let alert = UIAlertController(
            title: "Select Start Date",
            message: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",
            preferredStyle: .actionSheet
        )

        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.maximumDate = Date()

        alert.view.addSubview(datePicker)

        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 60),
            datePicker.widthAnchor.constraint(equalToConstant: 320),
            datePicker.heightAnchor.constraint(equalToConstant: 250)
        ])

        let select = UIAlertAction(title: "Done", style: .default) { _ in

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            self.startDate = formatter.string(from: datePicker.date)
            self.endDate = formatter.string(from: Date())

            Task {

                await MainActor.run {
                    OpaqueLoadingScreen.shared.show()
                }

                await YouTubeController.shared.restoreYouTubeConnectionIfNeeded(
                    startDate: self.startDate,
                    endDate: self.endDate
                )

                await self.loadAllData()

                await MainActor.run {
                    OpaqueLoadingScreen.shared.hide()
                }
            }
        }

        alert.addAction(select)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
    
//    func loadAudience() async {
//        do {
//            audienceMetrics = try await controller.fetchAudienceMetrics(
//                startDate: startDate,
//                            endDate: endDate
//            )
//            await MainActor.run {
//                self.analysisCollectionView.reloadData()
//            }
//            
//        } catch {
//            print("Error fetching audience:", error)
//        }
//    }
//    
//    func loadLatestContent() async {
//        do {
//            latestContent = try await controller.fetchLatestContent(
//                startDate: startDate,
//                            endDate: endDate
//            )
//            await MainActor.run {
//                self.analysisCollectionView.reloadData()
//            }
//            
//        } catch {
//            print("Error fetching latest content:", error)
//        }
//    }
//    
//    func loadTopVideos() async {
//        do {
//            topVideos = try await controller.fetchTopVideos(
//                startDate: startDate,
//                            endDate: endDate
//            )
//            await MainActor.run {
//                self.analysisCollectionView.reloadData()
//            }
//            
//        } catch {
//            print("Error fetching top video:", error)
//        }
//    }
//    
//    func loadRevenueInsights() async {
//        do {
//            revenueInsight = try await controller.fetchRevenueInsight(
//                startDate: startDate,
//                            endDate: endDate
//            )
//            await MainActor.run {
//                self.analysisCollectionView.reloadData()
//            }
//            
//        } catch {
//            print("Error fetching revenue insight:", error)
//        }
//    }
//    
//    func loadAudienceDemographic() async {
//        do {
//            async let audienceDemographic = try await controller.fetchAudienceDemographic(
//                startDate: startDate,
//                            endDate: endDate
//            )
//            
//            await MainActor.run {
//                self.analysisCollectionView.reloadData()
//            }
//            
//        } catch {
//            print("Error fetching revenue insight:", error)
//        }
//    }
//    
//    func loadViewerActivity() async {
//        do {
//            viewerActivity = try await controller.fetchViewerActivity()
//            print(viewerActivity)
//            
//            await MainActor.run {
//                self.analysisCollectionView.reloadData()
//            }
//            
//        } catch {
//            print("Error fetching viewer activity:", error)
//        }
//    }
    func loadAllData() async {

        do {

            async let audience = controller.fetchAudienceMetrics(
                startDate: startDate,
                endDate: endDate
            )

            async let latest = controller.fetchLatestContent()

            async let top = controller.fetchTopVideos(
                startDate: startDate,
                endDate: endDate
            )

            async let revenue = controller.fetchRevenueInsight(
                startDate: startDate,
                endDate: endDate
            )

            async let demo = controller.fetchAudienceDemographic(
                startDate: startDate,
                endDate: endDate
            )

            async let activity = controller.fetchViewerActivity(
                startDate: startDate,
                endDate: endDate
            )
            

            audienceMetrics = try await audience
            latestContent = try await latest
            topVideos = try await top
            revenueInsight = try await revenue
            audienceDemographic = try await demo
            viewerActivity = try await activity
            
            print(audienceMetrics)
            print(latestContent)
            print(topVideos)
            print(audienceDemographic)

            await MainActor.run {
                self.analysisCollectionView.reloadData()
            }

        } catch {
            print("Error loading analytics:", error)
        }
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
        return shouldShowRevenue ? 6 : 5
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if !shouldShowRevenue {
            switch section {
            case 0: return 4
            case 1: return 1
            case 2: return 3
            case 3: return 1
            case 4: return 1
            default: return 0
            }
        }
        
        switch section {
        case 0: return 4
        case 1: return 1
        case 2: return 3
        case 3: return 4
        case 4: return 1
        case 5: return 1
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var section = indexPath.section
        
        // Shift sections if revenue is hidden
        if !shouldShowRevenue && section >= 3 {
            section += 1
        }
        
        switch section {
            
        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "analysis_page_cell",
                for: indexPath
            ) as! AnalysisCell
            
            guard let latest = audienceMetrics.first else { return cell }
            
            switch indexPath.row {
            case 0: cell.configure(metric: .views, data: latest.views, audience: latest)
            case 1: cell.configure(metric: .likes, data: latest.likes, audience: latest)
            case 2: cell.configure(metric: .watchTime, data: latest.estimated_minutes_watched, audience: latest)
            case 3: cell.configure(metric: .subscribers, data: latest.subscribers, audience: latest)
            default: break
            }
            
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "latest_content_performance_cell",
                for: indexPath
            ) as! LatestContentPerformanceCell
            
            guard let latest = latestContent.first else { return cell }
            cell.configure(with: latest)
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "top_content_cell",
                for: indexPath
            ) as! TopContentCollectionViewCell
            
            guard topVideos.indices.contains(indexPath.row) else { return cell }
            
            let video = topVideos[indexPath.row]
            cell.configure(with: video)
            return cell
            
        case 3:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "revenue_cell",
                for: indexPath
            ) as! RevenueSourceCell
            
            guard let latest = revenueInsight.first else { return cell }
            
            switch indexPath.row {
            case 0: cell.configure(metric: .ads, data: latest.estimated_ad_revenue)
            case 1: cell.configure(metric: .paidContent, data: latest.gross_revenue)
            case 2: cell.configure(metric: .ypp, data: latest.ypp_revenue)
            case 3: cell.configure(metric: .collaboration, data: 20.00)
            default: break
            }
            
            return cell
            
        case 4:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "gender_analysis_cell",
                for: indexPath
            ) as! AudienceChartCell
            
            guard let latest = audienceDemographic.first else { return cell }
            cell.configure(with: latest)
            
            return cell
            
        case 5:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "optimal_time_cell",
                for: indexPath
            ) as! OptimalTimeChartCell
            
            cell.configure(with: viewerActivity)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: "header",
            withReuseIdentifier: "headerCell",
            for: indexPath
        ) as! HeaderView
        
        if shouldShowRevenue {
            switch indexPath.section {
            case 0: headerView.configureHeader(text: "Audience Metrics")
            case 1: headerView.configureHeader(text: "Latest Content Performance")
            case 2: headerView.configureHeader(text: "Top Content")
            case 3: headerView.configureHeader(text: "Revenue Insights")
            case 4: headerView.configureHeader(text: "Audience Demographic")
            case 5: headerView.configureHeader(text: "Optimal Upload Times")
            default: break
            }
        } else {
            switch indexPath.section {
            case 0: headerView.configureHeader(text: "Audience Metrics")
            case 1: headerView.configureHeader(text: "Latest Content Performance")
            case 2: headerView.configureHeader(text: "Top Content")
            case 3: headerView.configureHeader(text: "Audience Demographic")
            case 4: headerView.configureHeader(text: "Optimal Upload Times")
            default: break
            }
        }
        return headerView
    }
    
    func generateAnalysisLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            
            var section = sectionIndex
            
            // Shift sections when revenue is hidden
            if !self.shouldShowRevenue && section >= 3 {
                section += 1
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
            
            // MARK: Audience Metrics
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
                
                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(
                    top: 0, leading: 8, bottom: 0, trailing: 8
                )
                sectionLayout.boundarySupplementaryItems = [headerItem]
                
                return sectionLayout
            }
            
            // MARK: Latest Content
            if section == 1 {
                
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
                
                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.boundarySupplementaryItems = [makeHeaderItem()]
                
                return sectionLayout
            }
            
            // MARK: Top Content
            if section == 2 {
                
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
            
            // MARK: Revenue
            if section == 3 {
                
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(75)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(
                    top: 5, leading: 5, bottom: 5, trailing: 5
                )
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: itemSize,
                    subitems: [item]
                )
                
                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(
                    top: 0, leading: 8, bottom: 0, trailing: 8
                )
                sectionLayout.boundarySupplementaryItems = [headerItem]
                
                return sectionLayout
            }
            
            // MARK: Demographics
            if section == 4 {
                
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
                
                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.boundarySupplementaryItems = [makeHeaderItem()]
                
                return sectionLayout
            }
            
            // MARK: Upload Time
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(220)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 10, leading: 20, bottom: 10, trailing: 20
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: itemSize,
                subitems: [item]
            )
            
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.boundarySupplementaryItems = [makeHeaderItem()]
            
            return sectionLayout
        }
        
        return layout
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
    
    header.contentInsets = NSDirectionalEdgeInsets(
        top: 0,
        leading: 10,
        bottom: 0,
        trailing: 16
    )
    
    return header
}
