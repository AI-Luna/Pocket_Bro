//
//  RandomEvent.swift
//  Pocket Bro
//

import Foundation

struct RandomEvent: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let emoji: String
    let effects: [StatType: Int]
    let probability: Double
    let minStage: StartupStage
    let maxStage: StartupStage?
    let requiredMood: BroMood?
    let isPositive: Bool

    init(
        id: String,
        title: String,
        description: String,
        emoji: String,
        effects: [StatType: Int],
        probability: Double = 0.1,
        minStage: StartupStage = .garage,
        maxStage: StartupStage? = nil,
        requiredMood: BroMood? = nil,
        isPositive: Bool = true
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.emoji = emoji
        self.effects = effects
        self.probability = probability
        self.minStage = minStage
        self.maxStage = maxStage
        self.requiredMood = requiredMood
        self.isPositive = isPositive
    }

    static func == (lhs: RandomEvent, rhs: RandomEvent) -> Bool {
        lhs.id == rhs.id
    }

    func canTrigger(for state: BroState) -> Bool {
        if state.startup.stage.rawValue < minStage.rawValue { return false }
        if let maxStage = maxStage, state.startup.stage.rawValue > maxStage.rawValue { return false }
        if let requiredMood = requiredMood, state.mood != requiredMood { return false }
        return true
    }
}
