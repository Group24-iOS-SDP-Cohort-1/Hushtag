import Foundation

struct Post: Identifiable, Sendable {
    let id: UUID?
    let name: String
    let platform: [Platform]
    var tasks: [Tasks]
    let reminder: [Date]?
    let deadline: Date
    var isCompleted: Bool {
        guard !tasks.isEmpty else { return false }
        return tasks.allSatisfy { $0.isCompleted }
    }
}
struct Tasks: Identifiable, Sendable {
    let id: UUID
    let name: String
    let deadline: Date
    var isCompleted: Bool
}

nonisolated struct PostDB: Codable, Sendable {
    let id: UUID
    let user_id: UUID
    let name: String
    let deadline: Date
    let platform: [Platform]
    let reminder: [Date]?
    var isCompleted: Bool
}

nonisolated struct PostInsertPayload: Codable, Sendable {
    let user_id: UUID
    let name: String
    let deadline: Date
    let platform: [String]
    let reminder: [Date]
}

nonisolated struct TaskDB: Codable, Sendable {
    let id: UUID
    let post_id: UUID
    let name: String
    let deadline: Date
    var isCompleted: Bool
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
    
    var effectiveDeadline: Date {
        switch self {
        case .post(_, let task):
            //            if post.deadline == nil { return task.deadline }
            //            else if task.deadline == nil { return post.deadline }
            return task.deadline //?? post.deadline
            
        case .deal(_, let deliverable):
            return deliverable.deadline //?? deal.deadline
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
    func matches(post: Post, task: Tasks) -> Bool {
        guard case .post(let p, let t) = self else { return false }
        return p.id == post.id && t.id == task.id
    }
    
    func matches(deal: Deal, deliverable: Deliverable) -> Bool {
        guard case .deal(let d, let del) = self else { return false }
        return d.id == deal.id && del.id == deliverable.id
    }
}

enum Platform: String, Codable {
    case instagram
    case youtube
    case x
    case pinterest
    case others
}
