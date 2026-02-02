//
//  GameAction.swift
//  Pocket Bro
//

import Foundation

struct GameAction: Identifiable, Equatable {
    let id: String
    let name: String
    let category: ActionCategory
    let description: String
    let emoji: String
    let effects: [StatType: Int]
    let requirements: [StatType: Int]
    let cooldownSeconds: TimeInterval
    let minStage: StartupStage
    let triggersMinigame: MinigameType?
    let foodIconIndex: Int? // Index in food sprite sheet (0-5), nil if using emoji
    let socialIconIndex: Int? // Index in social sprite sheet (0-5), nil if using emoji
    let workIconIndex: Int? // Index in work sprite sheet (0-5), nil if using emoji

    init(
        id: String,
        name: String,
        category: ActionCategory,
        description: String,
        emoji: String,
        effects: [StatType: Int],
        requirements: [StatType: Int] = [:],
        cooldownSeconds: TimeInterval = 0,
        minStage: StartupStage = .garage,
        triggersMinigame: MinigameType? = nil,
        foodIconIndex: Int? = nil,
        socialIconIndex: Int? = nil,
        workIconIndex: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.emoji = emoji
        self.effects = effects
        self.requirements = requirements
        self.cooldownSeconds = cooldownSeconds
        self.minStage = minStage
        self.triggersMinigame = triggersMinigame
        self.foodIconIndex = foodIconIndex
        self.socialIconIndex = socialIconIndex
        self.workIconIndex = workIconIndex
    }

    static func == (lhs: GameAction, rhs: GameAction) -> Bool {
        lhs.id == rhs.id
    }

    func canPerform(with state: BroState) -> Bool {
        if state.startup.stage.rawValue < minStage.rawValue { return false }

        for (stat, minValue) in requirements {
            switch stat {
            case .energy, .health, .happiness, .social, .burnout:
                if state.stats[stat] < minValue { return false }
            case .funding, .product, .runway:
                if state.startup[stat] < minValue { return false }
            }
        }
        return true
    }

    func reasonCantPerform(with state: BroState) -> String? {
        if state.startup.stage.rawValue < minStage.rawValue {
            return "Requires \(minStage.displayName) stage"
        }

        for (stat, minValue) in requirements {
            let currentValue: Int
            switch stat {
            case .energy, .health, .happiness, .social, .burnout:
                currentValue = state.stats[stat]
            case .funding, .product, .runway:
                currentValue = state.startup[stat]
            }

            if currentValue < minValue {
                return "Need \(minValue) \(stat.displayName)"
            }
        }
        return nil
    }
}

// MARK: - Minigame Types

enum MinigameType: String, Codable {
    case dating
    case lockIn
}

// MARK: - Action Result

struct ActionResult {
    let action: GameAction
    let effectsApplied: [StatType: Int]
    let dialogue: String
    let triggeredEvent: RandomEvent?
    let stageAdvanced: Bool

    static func from(action: GameAction, dialogue: String, triggeredEvent: RandomEvent? = nil, stageAdvanced: Bool = false) -> ActionResult {
        ActionResult(
            action: action,
            effectsApplied: action.effects,
            dialogue: dialogue,
            triggeredEvent: triggeredEvent,
            stageAdvanced: stageAdvanced
        )
    }
}
