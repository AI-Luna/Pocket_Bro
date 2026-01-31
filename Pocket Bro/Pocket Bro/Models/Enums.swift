//
//  Enums.swift
//  Pocket Bro
//

import Foundation

// MARK: - Character Archetypes

enum Archetype: String, Codable, CaseIterable {
    case bro = "Tech Bro"
    case gal = "Tech Gal"
    case nonBinary = "Tech Enby"

    var pronoun: String {
        switch self {
        case .bro: return "he"
        case .gal: return "she"
        case .nonBinary: return "they"
        }
    }

    var possessive: String {
        switch self {
        case .bro: return "his"
        case .gal: return "her"
        case .nonBinary: return "their"
        }
    }
}

// MARK: - Startup Stages

enum StartupStage: Int, Codable, CaseIterable {
    case garage = 0
    case preSeed = 1
    case seed = 2
    case seriesA = 3
    case seriesB = 4
    case unicorn = 5

    var displayName: String {
        switch self {
        case .garage: return "Garage"
        case .preSeed: return "Pre-Seed"
        case .seed: return "Seed"
        case .seriesA: return "Series A"
        case .seriesB: return "Series B"
        case .unicorn: return "Unicorn 🦄"
        }
    }

    var fundingRequired: Int {
        switch self {
        case .garage: return 0
        case .preSeed: return 50
        case .seed: return 150
        case .seriesA: return 400
        case .seriesB: return 800
        case .unicorn: return 1500
        }
    }

    var productRequired: Int {
        switch self {
        case .garage: return 0
        case .preSeed: return 30
        case .seed: return 100
        case .seriesA: return 250
        case .seriesB: return 500
        case .unicorn: return 1000
        }
    }

    var next: StartupStage? {
        StartupStage(rawValue: rawValue + 1)
    }
}

// MARK: - Stat Types

enum StatType: String, Codable, CaseIterable {
    case energy
    case health
    case happiness
    case social
    case burnout
    case funding
    case product
    case runway

    var displayName: String {
        switch self {
        case .energy: return "Energy"
        case .health: return "Health"
        case .happiness: return "Happiness"
        case .social: return "Social"
        case .burnout: return "Burnout"
        case .funding: return "Funding"
        case .product: return "Product"
        case .runway: return "Runway"
        }
    }

    var emoji: String {
        switch self {
        case .energy: return "⚡"
        case .health: return "❤️"
        case .happiness: return "😊"
        case .social: return "👥"
        case .burnout: return "🔥"
        case .funding: return "💰"
        case .product: return "📱"
        case .runway: return "🛫"
        }
    }

    var isInverted: Bool {
        self == .burnout
    }

    var maxValue: Int {
        switch self {
        case .funding, .product: return 2000
        case .runway: return 365
        default: return 100
        }
    }
}

// MARK: - Action Categories

enum ActionCategory: String, Codable, CaseIterable {
    case feed
    case work
    case selfCare
    case social

    var displayName: String {
        switch self {
        case .feed: return "Feed"
        case .work: return "Work"
        case .selfCare: return "Self Care"
        case .social: return "Social"
        }
    }

    var emoji: String {
        switch self {
        case .feed: return "🍕"
        case .work: return "💻"
        case .selfCare: return "🧘"
        case .social: return "🎉"
        }
    }
}

// MARK: - Bro Mood

enum BroMood: String, Codable {
    case happy
    case neutral
    case tired
    case stressed
    case burnedOut
    case sick
    case lonely
    case excited

    var emoji: String {
        switch self {
        case .happy: return "😄"
        case .neutral: return "😐"
        case .tired: return "😴"
        case .stressed: return "😰"
        case .burnedOut: return "🫠"
        case .sick: return "🤒"
        case .lonely: return "😢"
        case .excited: return "🤩"
        }
    }
}

// MARK: - Game Over Reasons

enum GameOverReason: String, Codable {
    case burnout
    case health
    case social
    case runway

    var title: String {
        switch self {
        case .burnout: return "Burned Out!"
        case .health: return "Health Crisis!"
        case .social: return "Total Isolation!"
        case .runway: return "Out of Runway!"
        }
    }

    var message: String {
        switch self {
        case .burnout:
            return "The hustle culture finally caught up. Your bro collapsed from exhaustion and had to return to a corporate job."
        case .health:
            return "Neglecting health has consequences. Your bro had to abandon the startup for medical recovery."
        case .social:
            return "With no friends, family, or connections left, your bro realized the lonely path wasn't worth it."
        case .runway:
            return "The money ran out before the dream could take off. Your bro had to shut down and find a 'real job'."
        }
    }
}
