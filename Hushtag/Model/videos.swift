//
//  videos.swift
//  Hushtag
//
//  Created by SDC-USER on 03/02/26.
//
import Foundation

struct VideoDTO: Codable {
    let id: String
    let title: String
    let description: String
    let hashtags: [String]?
    let thumbnail: String
    let channel: String
    let views: Int
    let likes: Int
    let publishedAt: String
    let embeddings: [Double]?
}

struct SearchResponse: Codable {
    let videos: [VideoDTO]?
    let source: String?
}


struct YouTubeSearchRequest: Encodable {
    let query: String
//    let minViews: Int
//    let maxAgeInDays: Int
//    let limit: Int
}
