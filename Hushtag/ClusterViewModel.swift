//
//  ClusterViewModel.swift
//  Hushtag
//
//  Created by SDC-USER on 04/02/26.
//

import Foundation
import Combine

//@MainActor
//final class ClusterViewModel: ObservableObject {
//
//    @Published var labels: [Int] = []
//    @Published var outliers: [Int] = []
//
//    func runClustering(embeddings: [[Double]]) {
//        Task {
//            do {
//                let result = try await ClusterService()
//                    .cluster(embeddings: embeddings)
//
//                self.labels = result.clusters.labels
//                self.outliers = result.clusters.outliers
//
//                print("✅ Cluster labels:", self.labels)
//                print("🚨 Outliers:", self.outliers)
//
//            } catch {
//                print("❌ Clustering failed:", error)
//            }
//        }
//    }
//}

@MainActor
final class ClusterViewModel: ObservableObject {

    @Published var videos: [ClusteredVideo] = []
    @Published var clusterInfo: [String: ClusterLabelInfo] = [:]
    @Published var gaps: [String] = []

    func load(query: String) {
        Task {
            do {
                let result = try await ClusterService()
                    .fetchClusters(query: query)

                self.videos = result.videos
                self.clusterInfo = result.clusters
                self.gaps = result.gaps

                print("✅ Loaded videos:", self.videos.count)
                print("📌 Cluster titles:", self.clusterInfo)

            } catch {
                print("❌ Failed:", error)
            }
        }
    }
}
