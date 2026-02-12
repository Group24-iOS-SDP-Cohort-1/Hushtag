//
//  videos.swift
//  Hushtag
//
//  Created by SDC-USER on 03/02/26.
//
import Foundation

struct SearchResponse: Codable {
    let clusterIdeas: [ClusterIdeaDTO]
}

struct ClusterIdeaDTO: Codable, Identifiable {

    let clusterId: Int
    let theme: String
    let gaps: [String]
    let ideas: [GeminiIdeaDTO]
    let videos: [ClusteredVideo]

    // SwiftUI Identifiable
    var id: Int { clusterId }

    enum CodingKeys: String, CodingKey {
        case clusterId = "cluster_id"
        case theme
        case gaps
        case ideas
        case videos
    }
}

struct GeminiIdeaDTO: Codable {
    let title: String
    let description: String
    let format: String
    let hashtags: [String]
    let noveltyScore: Int

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case format
        case hashtags
        case noveltyScore
    }
}

struct ClusteredVideo: Codable, Identifiable {

    let videoId: String
    let title: String
    let description: String
    let thumbnail: String?
    let channel: String
    let views: Int
    let likes: Int
    let comments: Int
    let publishedAt: String
    let cluster: Int
    let isOutlier: Bool

    // SwiftUI Identifiable
    var id: String { videoId }

    enum CodingKeys: String, CodingKey {
        case videoId = "id"
        case title
        case description
        case thumbnail
        case channel
        case views
        case likes
        case comments
        case publishedAt
        case cluster
        case isOutlier
    }
}

struct YouTubeSearchRequest: Codable {
    let query: String
}


extension ClusteredVideo {
    func toVideo() -> Video {
        return Video(
            id: self.videoId,
            title: self.title,
            thumbnail: self.thumbnail ?? "",
            channel: self.channel,
            views: self.views,
            likes: self.likes,
            comments: self.comments,
            publishedAt: self.publishedAt,
            link: nil // ClusteredVideo doesn't include link
        )
    }
}
