import Foundation

nonisolated struct BrandDealIdea: Codable {
    let userId: UUID
    let dealId: UUID
    let scriptedIdeaId: UUID
    let createdAt: String?
}
