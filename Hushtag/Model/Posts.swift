import Foundation

struct Post: Identifiable, Sendable {
    let id: UUID
    let name: String
    let platform: [Platform]
    var tasks: [Tasks]
    let reminder: [String]
}
struct Tasks: Identifiable, Sendable {
    let id: UUID
    let name: String
    let deadline: Date
    var isCompleted: Bool
}

nonisolated struct PostDB: Codable, Sendable {
    let id: UUID
    let name: String
    let deadline: Date
    let platform: [Platform]
}

nonisolated struct TaskDB: Codable, Sendable {
    let id: UUID
    let post_id: UUID
    let name: String
    let deadline: Date
    let isCompleted: Bool
}

enum ScheduleItem: Identifiable, Sendable {
    case deal(deal: Deal, deliverable: Deliverable)
    case post(post: Post, task: Tasks)

    var id: UUID {
        switch self {
        case .deal(_, let deliverable):
            return deliverable.id
        case .post(_, let task):
            return task.id
        }
    }

    var date: Date {
        switch self {
        case .deal(_, let deliverable):
            return deliverable.deadline
        case .post(_, let task):
            return task.deadline
        }
    }

    var isCompleted: Bool {
        switch self {
        case .deal(_, let deliverable):
            return deliverable.isCompleted
        case .post(_, let task):
            return task.isCompleted
        }
    }
}

enum Platform: String, Codable {
    case instagram
    case youtube
    case x
    case pinterest
    case others
}
