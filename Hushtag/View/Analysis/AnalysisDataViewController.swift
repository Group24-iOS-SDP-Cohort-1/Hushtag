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

    private var emptyStateView: UIView?

    @IBOutlet var analysisCollectionView: UICollectionView!

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
        navigationItem.title = "\(platform.capitalized) Analysis"
        analysisCollectionView.dataSource = self
        analysisCollectionView.register(
            UINib(
                nibName: "AnalysisCell", bundle: nil
            ),
            forCellWithReuseIdentifier: "analysis_page_cell"
        )

        analysisCollectionView.register(
            UINib(nibName: "AudienceChartCell", bundle: nil),
            forCellWithReuseIdentifier: "gender_analysis_cell"
        )

        analysisCollectionView.register(
            UINib(
                nibName: "HeaderView",
                bundle: nil
            ),
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

        checkConnectionStatus()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkConnectionStatus()
    }

    private func checkConnectionStatus() {
        Task {
            let connected = await YouTubeController.shared.checkYouTubeConnection()
            await MainActor.run {
                self.isYouTubeConnected = connected
                self.updateUIForConnectionStatus()
                if connected {
                    Task {
                        await loadAllData()
                    }
                }
            }
        }
    }

    private func updateUIForConnectionStatus() {
        if isYouTubeConnected {
            emptyStateView?.removeFromSuperview()
            emptyStateView = nil
            analysisCollectionView.isHidden = false
        } else {
            showConnectYouTubePrompt()
            analysisCollectionView.isHidden = true
        }
    }

    private func showConnectYouTubePrompt() {
        if emptyStateView != nil { return }

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        emptyStateView = container

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        let imageView = UIImageView(image: UIImage(systemName: "play.rectangle.fill"))
        imageView.tintColor = UIColor(red: 0.545, green: 0.361, blue: 0.965, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = .init(pointSize: 60)

        let titleLabel = UILabel()
        titleLabel.text = "Connect YouTube Account"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .white

        let descLabel = UILabel()
        descLabel.text = "Connect your account to see your channel analytics and insights."
        descLabel.font = .systemFont(ofSize: 16)
        descLabel.textColor = .secondaryLabel
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0

        let connectButton = UIButton(type: .system)
        connectButton.setTitle("Connect Now", for: .normal)
        connectButton.backgroundColor = UIColor(red: 0.545, green: 0.361, blue: 0.965, alpha: 1.0)
        connectButton.setTitleColor(.white, for: .normal)
        connectButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        connectButton.layer.cornerRadius = 25
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        connectButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        connectButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        connectButton.addTarget(self, action: #selector(didTapConnectYouTube), for: .touchUpInside)

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descLabel)
        stackView.addArrangedSubview(connectButton)
    }

    @objc private func didTapConnectYouTube() {
        let viewModel = SignInModel()
        Task {
            do {
                try await viewModel.connectYouTube()

                // Fetch initial analytics to verify
                _ = try await YouTubeController.shared.fetchAnalytics(
                    startDate: self.startDate,
                    endDate: self.endDate
                )

                await MainActor.run {
                    CapsuleNotification.show(message: "YouTube Connected!", iconName: "checkmark.circle.fill")
                    self.isYouTubeConnected = true
                    self.updateUIForConnectionStatus()
                    Task {
                        await self.loadAllData()
                    }
                }
            } catch {
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Connection Failed",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
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
                    OpaqueLoadingScreen.shared
                        .show(message: "Fetching your channel analytics...")
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

    func loadAllData() async {
        guard isYouTubeConnected else { return }

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

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if let destination = segue.destination as? InsightsViewController {
            destination.audienceMetrics = audienceMetrics.first
            destination.latestContent = latestContent
        }
    }
}

extension AnalysisDataViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return shouldShowRevenue ? 6 : 5
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        var section = indexPath.section

        // Shift sections if revenue is hidden
        if !shouldShowRevenue && section >= 3 {
            section += 1
        }

        switch section {
        case 0: return audienceMetricsCell(at: indexPath, in: collectionView)
        case 1: return latestContentCell(at: indexPath, in: collectionView)
        case 2: return topContentCell(at: indexPath, in: collectionView)
        case 3: return revenueCell(at: indexPath, in: collectionView)
        case 4: return optimalTimeCell(at: indexPath, in: collectionView)
        case 5: return collectionView.dequeueReusableCell(withReuseIdentifier: "insight_cell", for: indexPath)
        default: return UICollectionViewCell()
        }
    }

    // MARK: - Cell helpers

    private func audienceMetricsCell(
        at indexPath: IndexPath,
        in collectionView: UICollectionView
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "analysis_page_cell",
            for: indexPath
        ) as? AnalysisCell else {
            return UICollectionViewCell()
        }

        guard let latest = audienceMetrics.first else { return cell }

        switch indexPath.row {
        case 0: cell.configure(metric: .views, data: latest.views, audience: latest)
        case 1: cell.configure(metric: .likes, data: latest.likes, audience: latest)
        case 2: cell.configure(metric: .watchTime, data: latest.estimatedMinutesWatched, audience: latest)
        case 3: cell.configure(metric: .subscribers, data: latest.subscribers, audience: latest)
        default: break
        }

        return cell
    }

    private func latestContentCell(
        at indexPath: IndexPath,
        in collectionView: UICollectionView
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "latest_content_performance_cell",
            for: indexPath
        ) as? LatestContentPerformanceCell else {
            return UICollectionViewCell()
        }

        guard let latest = latestContent.first else { return cell }
        cell.configure(with: latest)
        return cell
    }

    private func topContentCell(
        at indexPath: IndexPath,
        in collectionView: UICollectionView
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "top_content_cell",
            for: indexPath
        ) as? TopContentCollectionViewCell else {
            return UICollectionViewCell()
        }

        guard topVideos.indices.contains(indexPath.row) else { return cell }

        let video = topVideos[indexPath.row]
        cell.configure(with: video)
        return cell
    }

    private func revenueCell(
        at indexPath: IndexPath,
        in collectionView: UICollectionView
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "revenue_cell",
            for: indexPath
        ) as? RevenueSourceCell else {
            return UICollectionViewCell()
        }

        guard let latest = revenueInsight.first else { return cell }

        switch indexPath.row {
        case 0: cell.configure(metric: .ads, data: latest.estimatedAdRevenue)
        case 1: cell.configure(metric: .paidContent, data: latest.grossRevenue)
        case 2: cell.configure(metric: .ypp, data: latest.yppRevenue)
        case 3: cell.configure(metric: .collaboration, data: 20.00)
        default: break
        }

        return cell
    }

    private func optimalTimeCell(
        at indexPath: IndexPath,
        in collectionView: UICollectionView
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "optimal_time_cell",
            for: indexPath
        ) as? OptimalTimeChartCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: viewerActivity)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind _: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: "header",
            withReuseIdentifier: "headerCell",
            for: indexPath
        ) as? HeaderView else {
            return UICollectionReusableView()
        }

        if shouldShowRevenue {
            switch indexPath.section {
            case 0: headerView.configureHeader(text: "Audience Metrics")
            case 1: headerView.configureHeader(text: "Latest Content Performance")
            case 2: headerView.configureHeader(text: "Top Content")
            case 3: headerView.configureHeader(text: "Revenue Insights")
            case 4: headerView.configureHeader(text: "Optimal Upload Times")
            default: break
            }
        } else {
            switch indexPath.section {
            case 0: headerView.configureHeader(text: "Audience Metrics")
            case 1: headerView.configureHeader(text: "Latest Content Performance")
            case 2: headerView.configureHeader(text: "Top Content")
            case 3: headerView.configureHeader(text: "Optimal Upload Times")
            default: break
            }
        }
        return headerView
    }

    func generateAnalysisLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            var section = sectionIndex
            if !self.shouldShowRevenue && section >= 3 { section += 1 }
            switch section {
            case 0: return self.audienceMetricsLayout()
            case 1: return self.latestContentLayout()
            case 2: return self.topContentLayout()
            case 3: return self.revenueLayout()
            case 4: return self.uploadTimeLayout()
            default:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(100)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
                return NSCollectionLayoutSection(group: group)
            }
        }
    }

    private func audienceMetricsLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(110)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)
        let rowSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(122)
        )
        let row = NSCollectionLayoutGroup.horizontal(layoutSize: rowSize, repeatingSubitem: item, count: 2)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(244)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [row])
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize, elementKind: "header", alignment: .top
        )
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        sectionLayout.boundarySupplementaryItems = [headerItem]
        return sectionLayout
    }

    private func latestContentLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(180)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.boundarySupplementaryItems = [makeHeaderItem()]
        return sectionLayout
    }

    private func topContentLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(90)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.boundarySupplementaryItems = [makeHeaderItem()]
        return sectionLayout
    }

    private func revenueLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(75)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize, elementKind: "header", alignment: .top
        )
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        sectionLayout.boundarySupplementaryItems = [headerItem]
        return sectionLayout
    }

    private func uploadTimeLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(220)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.boundarySupplementaryItems = [makeHeaderItem()]
        return sectionLayout
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
