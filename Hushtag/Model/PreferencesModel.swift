import Foundation

nonisolated struct PreferenceInsertPayload: Codable {
    let user_id: UUID
    let niche: [String]
    let content_goals: [String]
    let content_length: [String]
    let content_type: [String]
    let youtube_connection: Bool
}

struct UserPreference {
    let user_id: UUID
    let niche: [Niche]
    let contentGoals: [ContentGoal]
    let contentLength: [ContentLength]
    let contentType: [ContentType]
    let isYoutubeConnected: Bool
}

nonisolated struct PreferenceDB: Codable, Sendable {
    let id: UUID
    let user_id: UUID
    let created_at: Date
    let niche: [Niche]?
    let content_goals: [ContentGoal]?
    let content_length: [ContentLength]?
    let content_type: [ContentType]?
    let youtube_connection: Bool?
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

enum ContentType: String, Codable, CustomStringConvertible {
    case funny
    case relatable
    case casual
    case aesthetic
    case trendy
    case motivational
    case lowkey
    case sciFi = "sci-fi"
    case other
    
    var description: String {
        rawValue
    }
}

enum ContentLength: String, Codable, CustomStringConvertible {
    case shortForm = "short-form"
    case longForm = "long-form"
    var description: String {
        rawValue
    }
}

enum ContentGoal: String, Codable, CustomStringConvertible {
    case growth
    case engagement
    case consistency
    case creativity
    case branding
    var description: String {
        rawValue
    }
}



struct PreferenceItem {
    let id: Int
    let title: String
    let subheading: String
    let sections: [PreferenceSection]
}

struct PreferenceSection {
    var title: String = ""
    var hasTextInput: Bool = false
    var options: [String] = []
}

struct PreferencesData {
    static let items: [PreferenceItem] = [
        PreferenceItem(
            id: 1,
            title: "Pick your niche",
            subheading: "Choose topics you want to create content about",
            sections: [
                PreferenceSection(
                    title: "",
                    hasTextInput: false,
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
                )
            ]
        ),
        PreferenceItem(
            id: 2,
            title: "Set your content goals",
            subheading: "Select your main content goals",
            sections: [
                PreferenceSection(
                    title: "",
                    hasTextInput: false,
                    options: [
                        "Grow Audience",
                        "Boost Engagement",
                        "Post More Consistently",
                        "Experiment with Trends",
                        "Strengthen My Brand"
                    ]
                )
            ]
        ),
        PreferenceItem(
            id: 3,
            title: "Content Preferences",
            subheading: "Tone and format preferences",
            sections: [
                PreferenceSection(
                    title: "What best describes your vibe?",
                    hasTextInput: false,
                    options: [
                        "Funny",
                        "Relatable",
                        "Casual",
                        "Motivational",
                        "Aesthetic",
                        "Trendy",
                        "Other"
                    ]
                ),
                PreferenceSection(
                    title: "What kind of content do you prefer making?",
                    hasTextInput: false,
                    options: [
                        "Short-Form",
                        "Long-Form"
                    ]
                )
            ]
        ),
        PreferenceItem(
            id: 4,
            title: "Add your YouTube account",
            subheading: "Link your YouTube account to get personalized insights on current trends, detailed analysis of your videos and account insights.",
            sections: [
                PreferenceSection(
                    title: "",
                    hasTextInput: false,
                    options: [
                        "Connect YouTube",
                        "Connect Instagram",
                        "Connect Facebook"
                    ]
                )
            ]
        )
    ]
}
