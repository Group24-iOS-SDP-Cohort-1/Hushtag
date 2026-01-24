import Foundation


nonisolated struct Deal: Identifiable, Sendable {
    let id: UUID
    let name: String
    var deliverables: [Deliverable]
    let platform: [String]
    let phone: String
    let email: String
    let description: String
    let payment: Int
}

nonisolated struct Deliverable: Sendable {
    let name: String
    let deadline: Date
    var isCompleted: Bool
}

nonisolated struct DealInsertPayload: Encodable, Sendable{
    let name: String
    let payment: Double
    let mobileNumber: String
    let email: String
    let description: String
    let deadline: Date
    let platform: String
}

nonisolated struct DealDB: Decodable, Sendable {
    let id: UUID
    let name: String
    let payment: Double
    let mobileNumber: String?
    let email: String?
    let description: String?
    let deadline: Date
    let platform: String
}

nonisolated struct DeliverableDB: Codable, Sendable {
    let deal_id: UUID?
    let name: String
    let deadline: Date
    let isCompleted: Bool
}


nonisolated struct DealWithDeliverables: Decodable, Sendable {
    let id: UUID
    let name: String
    let payment: Double
    let mobileNumber: String?
    let email: String?
    let description: String?
    let platform: String
    let deliverables: [DeliverableDB]
}


