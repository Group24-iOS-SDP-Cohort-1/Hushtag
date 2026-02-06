//
//  Cluster.swift
//  Hushtag
//
//  Created by SDC-USER on 04/02/26.
//

import Foundation

struct ClusterResponse: Codable {
    let videos: [ClusteredVideo]

    let clusters: [String: ClusterLabelInfo]
    let gaps: [String]
}


struct ClusterResult: Codable {
    let labels: [Int]
    let outliers: [Int]
}

struct ClusteredVideo: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let thumbnail: String?
    let channel: String
    let views: Int
    let likes: Int
    let publishedAt: String

    let cluster: Int
    let isOutlier: Bool

    let clusterTitle: String?
    let clusterDescription: String?
    let clusterKeywords: [String]
}

struct ClusterLabelInfo: Codable {
    let title: String
    let description: String
    let keywords: [String]
}

