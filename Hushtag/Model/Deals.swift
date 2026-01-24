import Foundation


struct Deal: Identifiable, Sendable {
    let id: UUID
    let name: String
    let payment: Double
    let mobileNumber: Int64
    let email: String
    let description: String
    let platform: [String]
    var deliverables: [Deliverable]
}
struct Deliverable: Identifiable, Sendable {
    let id: UUID
    let name: String
    let deadline: Date
    var isCompleted: Bool
}

nonisolated struct DealDB: Codable, Sendable {
    let id: UUID
    let name: String
    let payment: Double?   
    let mobileNumber: Int64?
    let email: String?
    let description: String?
    let deadline: Date
    let platform: String
}

nonisolated struct DeliverableDB: Codable, Sendable {
    let id: UUID    
    let deal_id: UUID
    let name: String
    let deadline: Date
    let isCompleted: Bool
}


