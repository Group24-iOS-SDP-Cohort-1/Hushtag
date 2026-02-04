//
//  Cluster.swift
//  Hushtag
//
//  Created by SDC-USER on 04/02/26.
//

import Foundation

struct ClusterResponse: Codable {
    let clusters: ClusterResult
    let embeddingsCount: Int

    enum CodingKeys: String, CodingKey {
        case clusters
        case embeddingsCount = "embeddings_count"
    }
}

struct ClusterResult: Codable {
    let labels: [Int]
    let outliers: [Int]
}
