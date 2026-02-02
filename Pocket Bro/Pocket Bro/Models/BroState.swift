//
//  BroState.swift
//  Pocket Bro
//

import Foundation

// MARK: - City

enum City: String, Codable, CaseIterable {
    case sanFrancisco = "San Francisco"
    case newYork = "New York"

    var daytimeImageName: String {
        switch self {
        case .sanFrancisco: return "SFDaytime"
        case .newYork: return "NYCDaytime"
        }
    }

    var nighttimeImageName: String {
        switch self {
        case .sanFrancisco: return "SFNighttime"
        case .newYork: return "NYCNighttime"
        }
    }

    /// Returns the appropriate image name based on current local time
    var currentImageName: String {
        return City.isNighttime ? nighttimeImageName : daytimeImageName
    }

    /// For backward compatibility
    var imageName: String {
        return currentImageName
    }

    var emoji: String {
        switch self {
        case .sanFrancisco: return "🌉"
        case .newYork: return "🗽"
        }
    }

    /// Returns true if the current local time is considered nighttime (7 PM - 6 AM)
    static var isNighttime: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 19 || hour < 6
    }
}

// MARK: - Bro Stats

struct BroStats: Codable, Equatable {
    var energy: Int
    var health: Int
    var happiness: Int
    var social: Int
    var burnout: Int

    static let initial = BroStats(
        energy: 80,
        health: 100,
        happiness: 70,
        social: 60,
        burnout: 10
    )

    subscript(stat: StatType) -> Int {
        get {
            switch stat {
            case .energy: return energy
            case .health: return health
            case .happiness: return happiness
            case .social: return social
            case .burnout: return burnout
            default: return 0
            }
        }
        set {
            let clamped = max(0, min(newValue, stat.maxValue))
            switch stat {
            case .energy: energy = clamped
            case .health: health = clamped
            case .happiness: happiness = clamped
            case .social: social = clamped
            case .burnout: burnout = clamped
            default: break
            }
        }
    }

    mutating func apply(effects: [StatType: Int]) {
        for (stat, delta) in effects {
            self[stat] = self[stat] + delta
        }
    }
}

// MARK: - Startup State

struct StartupState: Codable, Equatable {
    var stage: StartupStage
    var funding: Int
    var product: Int
    var runway: Int

    static let initial = StartupState(
        stage: .garage,
        funding: 0,
        product: 0,
        runway: 90
    )

    subscript(stat: StatType) -> Int {
        get {
            switch stat {
            case .funding: return funding
            case .product: return product
            case .runway: return runway
            default: return 0
            }
        }
        set {
            let clamped = max(0, min(newValue, stat.maxValue))
            switch stat {
            case .funding: funding = clamped
            case .product: product = clamped
            case .runway: runway = clamped
            default: break
            }
        }
    }

    mutating func apply(effects: [StatType: Int]) {
        for (stat, delta) in effects {
            self[stat] = self[stat] + delta
        }
    }

    var canAdvanceStage: Bool {
        guard let nextStage = stage.next else { return false }
        return funding >= nextStage.fundingRequired && product >= nextStage.productRequired
    }

    mutating func tryAdvanceStage() -> Bool {
        guard let nextStage = stage.next, canAdvanceStage else { return false }
        stage = nextStage
        return true
    }
}

// MARK: - Full Bro State

struct BroState: Codable, Equatable {
    var name: String
    var archetype: Archetype
    var city: City
    var stats: BroStats
    var startup: StartupState
    var createdAt: Date
    var lastPlayedAt: Date
    var totalActionsPerformed: Int
    var eventsExperienced: [String]

    static func new(name: String, archetype: Archetype, city: City = .sanFrancisco) -> BroState {
        let now = Date()
        return BroState(
            name: name,
            archetype: archetype,
            city: city,
            stats: .initial,
            startup: .initial,
            createdAt: now,
            lastPlayedAt: now,
            totalActionsPerformed: 0,
            eventsExperienced: []
        )
    }

    var mood: BroMood {
        if stats.burnout >= 90 { return .burnedOut }
        if stats.health <= 20 { return .sick }
        if stats.social <= 20 { return .lonely }
        if stats.energy <= 20 { return .tired }
        if stats.burnout >= 70 { return .stressed }
        if stats.happiness >= 80 && stats.energy >= 60 { return .excited }
        if stats.happiness >= 50 { return .happy }
        return .neutral
    }

    var isGameOver: Bool {
        gameOverReason != nil
    }

    var gameOverReason: GameOverReason? {
        if stats.burnout >= 100 { return .burnout }
        if stats.health <= 0 { return .health }
        if stats.social <= 0 { return .social }
        if startup.runway <= 0 { return .runway }
        return nil
    }

    var isVictory: Bool {
        startup.stage == .unicorn
    }

    mutating func applyEffects(_ effects: [StatType: Int]) {
        var broStatEffects: [StatType: Int] = [:]
        var startupEffects: [StatType: Int] = [:]

        for (stat, delta) in effects {
            switch stat {
            case .energy, .health, .happiness, .social, .burnout:
                broStatEffects[stat] = delta
            case .funding, .product, .runway:
                startupEffects[stat] = delta
            }
        }

        stats.apply(effects: broStatEffects)
        startup.apply(effects: startupEffects)
    }
}
