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
    //let reminder: [Date]
    var isCompleted: Bool {
        guard !deliverables.isEmpty else { return false }
        return deliverables.allSatisfy { $0.isCompleted }
    }
}
struct Deliverable: Identifiable, Sendable {
    let id: UUID
    let name: String
    let deadline: Date
    var isCompleted: Bool
}

nonisolated struct DealDB: Codable, Sendable {
    let id: UUID
    let user_id: UUID
    let name: String
    let payment: Double?
    let mobileNumber: Int64?
    let email: String?
    let description: String?
    let deadline: Date
    let platform: String
    var isCompleted: Bool
}

nonisolated struct DeliverableDB: Codable, Sendable {
    let id: UUID
    let deal_id: UUID
    let name: String
    let deadline: Date
    let isCompleted: Bool
}

nonisolated struct DealInsertPayload: Encodable, Sendable{
    let user_id: UUID
    let name: String
    let payment: Double
    let mobileNumber: Int64
    let email: String
    let deadline: Date
    let platform: String
}
