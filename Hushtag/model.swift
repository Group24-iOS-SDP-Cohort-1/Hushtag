//
//  model.swift
//  Hushtag
//
//  Created by SDC-USER on 22/01/26.
//

import Foundation

struct TestPing: Codable, Identifiable, Sendable {
    let id: UUID?
    let message: String
}
