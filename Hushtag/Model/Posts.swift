import Foundation

struct Post: Identifiable {
    let id: UUID?
    let name: String
    let platform: [Platform]
    var tasks: [Tasks]
    let reminder: [Date]?
    let deadline: Date
    var isManuallyCompleted: Bool = false

    var isCompleted: Bool {
        if tasks.isEmpty {
            return isManuallyCompleted
        }
        return tasks.allSatisfy { $0.isCompleted }
    }
}

struct Tasks: Identifiable {
    let id: UUID
    var name: String
    var deadline: Date
    var isCompleted: Bool
}

nonisolated struct PostDB: Codable {
    let post_id: UUID
    let user_id: UUID
    let name: String
    let deadline: Date
    let platform: [Platform]
    let reminder: [Date]?
    var isCompleted: Bool
}

nonisolated struct PostInsertPayload: Codable {
    let user_id: UUID
    let name: String
    let deadline: Date
    let platform: [String]
    let reminder: [Date]
    let isCompleted: Bool
}

nonisolated struct TaskDB: Codable {
    let id: UUID
    let post_id: UUID
    let name: String
    let deadline: Date
    var isCompleted: Bool
}

enum ScheduleItem: Identifiable {
    case deal(deal: Deal, deliverable: Deliverable?)
    case post(post: Post, task: Tasks?)

    var id: UUID {
        switch self {
        case let .deal(deal, deliverable):
            return deliverable?.id ?? deal.id
        case let .post(post, task):
            return task?.id ?? post.id ?? UUID()
        }
    }

    var effectiveDeadline: Date {
        switch self {
        case let .post(post, task):
            return task?.deadline ?? post.deadline

        case let .deal(deal, deliverable):
            return deliverable?.deadline ?? deal.deadline
        }
    }

    var date: Date {
        return effectiveDeadline
    }

    func matches(post: Post, task: Tasks?) -> Bool {
        guard case let .post(p, t) = self else { return false }
        return p.id == post.id && t?.id == task?.id
    }

    func matches(deal: Deal, deliverable: Deliverable?) -> Bool {
        guard case let .deal(d, del) = self else { return false }
        return d.id == deal.id && del?.id == deliverable?.id
    }
}

enum Platform: String, Codable, CaseIterable {
    case instagram
    case youtube
    case x
    case pinterest
    case others

    var description: String {
        switch self {
        case .instagram: return "Instagram"
        case .youtube: return "YouTube"
        case .x: return "X"
        case .pinterest: return "Pinterest"
        case .others: return "Others"
        }
    }
}
