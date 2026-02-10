//
//  clusterService.swift
//  Hushtag
//
//  Created by SDC-USER on 04/02/26.
//

import Foundation

final class ClusterService {

    private let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp1dXV3dXlkbGdqaGd3d2Fic3d5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkwMTEwMzAsImV4cCI6MjA4NDU4NzAzMH0.qTJ2zoIj3uBR5tSOp8-J-dU0ZPJIE_XKkw23zP4-sRg"
    private let projectURL = "https://juuuwuydlgjhgwwabswy.supabase.co"

//    func cluster(embeddings: [[Double]]) async throws -> ClusterResponse {
//
//        let url = URL(string: "\(projectURL)/functions/v1/cluster")!
//        var request = URLRequest(url: url)
//
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
//        request.addValue(anonKey, forHTTPHeaderField: "apikey")
//
//        let body = ["embeddings": embeddings]
//        request.httpBody = try JSONEncoder().encode(body)
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//
//        // 🔍 Debug
//        print("RAW CLUSTER RESPONSE:",
//              String(data: data, encoding: .utf8) ?? "nil")
//
//        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
//            throw URLError(.badServerResponse)
//        }
//
//        return try JSONDecoder().decode(ClusterResponse.self, from: data)
//    }
    
    func fetchClusters(query: String) async throws -> SearchResponse {

        let url = URL(string: "\(projectURL)/functions/v1/cluster")!
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.addValue(anonKey, forHTTPHeaderField: "apikey")

        let body = ["query": query]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        print("RAW EDGE RESPONSE:", String(data: data, encoding: .utf8) ?? "nil")

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(SearchResponse.self, from: data)
    }
}
