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
    var name: String
    var deadline: Date
    var isCompleted: Bool
}

nonisolated struct PostDB: Codable, Sendable {
    let post_id: UUID
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
    // 1. Made task and deliverable optional
    case deal(deal: Deal, deliverable: Deliverable?)
    case post(post: Post, task: Tasks?)
    
    var id: UUID {
        switch self {
        case .deal(let deal, let deliverable):
            // Fall back to deal's ID if no deliverable
            return deliverable?.id ?? deal.id
        case .post(let post, let task):
            // Fall back to post's ID if no task (provide a default UUID if post.id is nil)
            return task?.id ?? post.id ?? UUID()
        }
    }
    
    var effectiveDeadline: Date {
        switch self {
        case .post(let post, let task):
            // Fall back to the main post's deadline
            return task?.deadline ?? post.deadline
            
        case .deal(let deal, let deliverable):
            // Fall back to the main deal's deadline
            return deliverable?.deadline ?? deal.deadline
        }
    }
    
    var date: Date {
        // This does the exact same thing as effectiveDeadline now
        return effectiveDeadline
    }
    
    // 2. Updated matches functions to handle optional sub-items
    func matches(post: Post, task: Tasks?) -> Bool {
        guard case .post(let p, let t) = self else { return false }
        return p.id == post.id && t?.id == task?.id
    }
    
    func matches(deal: Deal, deliverable: Deliverable?) -> Bool {
        guard case .deal(let d, let del) = self else { return false }
        return d.id == deal.id && del?.id == deliverable?.id
    }
}

enum Platform: String, Codable , CaseIterable {
    case instagram
    case youtube
    case x
    case pinterest
    case others
    
    var description : String {
        switch self {
        case .instagram: return "Instagram"
        case .youtube: return "YouTube"
        case .x: return "X"
        case .pinterest: return "Pinterest"
        case .others: return "Others"
        }
    }
}
