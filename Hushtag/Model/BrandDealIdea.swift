import Foundation

nonisolated struct BrandDealIdea: Codable {
    let user_id: UUID
    let deal_id: UUID
    let scripted_idea_id: UUID
    let created_at: String?
}
