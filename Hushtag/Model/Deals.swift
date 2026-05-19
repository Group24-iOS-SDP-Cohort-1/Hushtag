import Foundation

struct Deal: Identifiable {
    let id: UUID
    let name: String
    let payment: Double
    let mobileNumber: Int64
    let email: String
    let deadline: Date
    let platform: [Platform]
    var deliverables: [Deliverable]
    let reminder: [Date]?
    var isManuallyCompleted: Bool = false

    var isCompleted: Bool {
        if deliverables.isEmpty {
            return isManuallyCompleted
        }
        return deliverables.allSatisfy { $0.isCompleted }
    }
}

struct Deliverable: Identifiable {
    let id: UUID
    let dealId: UUID
    var name: String
    var deadline: Date
    var isCompleted: Bool
}

nonisolated struct DealDB: Codable {
    let dealId: UUID
    let userId: UUID
    let name: String
    let payment: Double?
    let mobileNumber: Int64?
    let email: String?
    let deadline: Date
    let reminder: [Date]?
    let platform: [Platform]
    var isCompleted: Bool
}

nonisolated struct DeliverableDB: Codable {
    let id: UUID
    let dealId: UUID
    let name: String
    let deadline: Date
    let isCompleted: Bool
}

nonisolated struct DealInsertPayload: Encodable {
    let userId: UUID
    let name: String
    let payment: Double
    let mobileNumber: Int64
    let email: String
    let deadline: Date
    let reminder: [Date]?
    let platform: [String]
    let isCompleted: Bool
}
