import Foundation

nonisolated struct PreferenceInsertPayload: Codable {
    let userId: UUID
    let niche: [String]
    let platform: [String]
}

struct UserPreference {
    let userId: UUID
    let niche: [Niche]
    let platform: [Platforms]
}

nonisolated struct PreferenceDB: Codable {
    let id: UUID
    let userId: UUID
    let createdAt: Date
    let niche: [Niche]?
    let platform: [Platforms]?
}

enum Platforms: String, Codable, CustomStringConvertible {
    case youtube
    case instagram
    case x
    var description: String {
        rawValue
    }
}

enum Niche: String, Codable, CustomStringConvertible {
    case beauty
    case lifestyle
    case fashion
    case skincare
    case food
    case wellness
    case music
    case game
    case education
    case finance
    case dance
    case others
    var description: String {
        rawValue
    }
}

struct PreferenceItem {
    let id: Int
    let title: String
    let options: [String]
}

enum PreferencesData {
    static let items: [PreferenceItem] = [
        PreferenceItem(
            id: 1,
            title: "Pick your niche",
            options: [
                "Lifestyle",
                "Skincare",
                "Game",
                "Food",
                "Wellness",
                "Finance",
                "Music",
                "Education",
                "Other"
            ]
        ),
        PreferenceItem(
            id: 2,
            title: "Choose Platform",
            options: [
                "Youtube",
                "Instagram",
                "X (Twitter)"
            ]
        )
    ]
}
