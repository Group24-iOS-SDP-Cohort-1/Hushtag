import UIKit

extension AnalysisDataViewController: UICollectionViewDataSource {
    func numberOfSections(in _: UICollectionView) -> Int {
        return shouldShowRevenue ? 6 : 5
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !shouldShowRevenue {
            let counts = [4, 1, 3, 1, 1]
            return section < counts.count ? counts[section] : 0
        }
        let counts = [4, 1, 3, 4, 1, 1]
        return section < counts.count ? counts[section] : 0
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

        let titlesWithRevenue = [
            "Audience Metrics", "Latest Content Performance", "Top Content", "Revenue Insights", "Optimal Upload Times"
        ]
        let titlesWithoutRevenue = [
            "Audience Metrics", "Latest Content Performance", "Top Content", "Optimal Upload Times"
        ]
        let titles = shouldShowRevenue ? titlesWithRevenue : titlesWithoutRevenue
        if indexPath.section < titles.count {
            headerView.configureHeader(text: titles[indexPath.section])
        }

        return headerView
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
}
