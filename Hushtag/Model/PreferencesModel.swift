//
//  PreferencesModel.swift
//  Hushtag
//
//  Created by Dhruav Mathur on 28/01/26.
//

import Foundation

nonisolated struct PreferenceInsertPayload: Codable {
    let user_id: UUID
    let niche: [String]
    let platform: [String]
}

struct UserPreference {
    let user_id: UUID
    let niche: [Niche]
    let platform: [Platforms]
}

nonisolated struct PreferenceDB: Codable, Sendable {
    let id: UUID
    let user_id: UUID
    let created_at: Date
    let niche: [Niche]?
    let platform: [Platforms]?
}

enum Platforms: String, Codable, CustomStringConvertible{
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
            title: "Choose Platform",
            subheading: "Pick your preferred platform",
            sections: [
                PreferenceSection(
                    title: "",
                    hasTextInput: false,
                    options: [
                        "Youtube",
                        "Instagram",
                        "X (Twitter)"
                    ]
                )
            ]
        )
    ]
}
