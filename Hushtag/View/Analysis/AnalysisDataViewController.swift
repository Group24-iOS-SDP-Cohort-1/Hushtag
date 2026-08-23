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
    var isYouTubeConnected: Bool = true

    var emptyStateView: UIView?

    @IBOutlet var analysisCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDates()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleYouTubeConnectionChanged),
            name: .youtubeConnectionChanged,
            object: nil
        )

        setupCollectionView()
        checkConnectionStatus()
    }

    @objc func handleYouTubeConnectionChanged() {
        checkConnectionStatus()
    }

    private func setupDates() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        endDate = formatter.string(from: Date())
        startDate = formatter.string(
            from: Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        )
    }

    private func setupCollectionView() {
        analysisCollectionView.register(
            UINib(nibName: "LatestContentPerformanceCell", bundle: nil),
            forCellWithReuseIdentifier: "latest_content_performance_cell"
        )
        analysisCollectionView.register(
            UINib(nibName: "TopContentCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "top_content_cell"
        )
        navigationItem.title = "\(platform.capitalized) Analysis"
        analysisCollectionView.dataSource = self
        analysisCollectionView.register(
            UINib(nibName: "AnalysisCell", bundle: nil),
            forCellWithReuseIdentifier: "analysis_page_cell"
        )
        analysisCollectionView.register(
            UINib(nibName: "AudienceChartCell", bundle: nil),
            forCellWithReuseIdentifier: "gender_analysis_cell"
        )
        analysisCollectionView.register(
            UINib(nibName: "HeaderView", bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "headerCell"
        )
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkConnectionStatus()
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
    var hasNoYouTubeData: Bool {
        return audienceMetrics.isEmpty && latestContent.isEmpty && topVideos.isEmpty && viewerActivity.isEmpty
    }

    func loadAllData() async {
        guard isYouTubeConnected else { return }

        // 1. Clear previous account data in memory
        await MainActor.run {
            self.audienceMetrics = []
            self.latestContent = []
            self.topVideos = []
            self.revenueInsight = []
            self.audienceDemographic = []
            self.viewerActivity = []
        }

        do {
            // 2. Trigger YouTube backend to pull fresh analytics for the connected channel
            _ = try? await YouTubeController.shared.fetchAnalytics(
                startDate: startDate,
                endDate: endDate
            )

            // 3. Fetch newly synced records from database
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
                if self.hasNoYouTubeData {
                    self.showNoDataView()
                } else {
                    self.emptyStateView?.removeFromSuperview()
                    self.emptyStateView = nil
                    self.analysisCollectionView.isHidden = false
                    self.analysisCollectionView.reloadData()
                }
            }

        } catch {
            print("Error loading analytics:", error)
            await MainActor.run {
                if self.hasNoYouTubeData {
                    self.showNoDataView()
                }
            }
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

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if let destination = segue.destination as? InsightsViewController {
            destination.audienceMetrics = audienceMetrics.first
            destination.latestContent = latestContent
        }
    }
}

extension Notification.Name {
    static let youtubeConnectionChanged = Notification.Name("youtubeConnectionChanged")
}
