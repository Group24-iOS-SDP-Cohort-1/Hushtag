//
//  ClusterViewModel.swift
//  Hushtag
//
//  Created by SDC-USER on 04/02/26.
//

import Foundation
import Combine

@MainActor
final class ClusterViewModel: ObservableObject {

    @Published var labels: [Int] = []
    @Published var outliers: [Int] = []

    func runClustering(embeddings: [[Double]]) {
        Task {
            do {
                let result = try await ClusterService()
                    .cluster(embeddings: embeddings)

                self.labels = result.clusters.labels
                self.outliers = result.clusters.outliers

                print("✅ Cluster labels:", self.labels)
                print("🚨 Outliers:", self.outliers)

            } catch {
                print("❌ Clustering failed:", error)
            }
        }
    }
}
