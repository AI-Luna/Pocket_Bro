//
//  FeedingActions.swift
//  Pocket Bro
//

import Foundation

// Food icon indices in sprite sheet (3 cols x 2 rows):
// 0: Energy Drink  1: Protein Shake  2: Ramen
// 3: Takeout Bag   4: Salad          5: Pizza

enum FeedingActions {
    static let all: [GameAction] = [
        energyDrink,
        soylent,
        ramen,
        doordash,
        healthyMeal,
        teamLunch
    ]

    static let energyDrink = GameAction(
        id: "feed_energy_drink",
        name: "Energy Drink",
        category: .feed,
        description: "Quick caffeine boost. Cheap but not healthy.",
        emoji: "🥤",
        effects: [
            .energy: 20,
            .health: -5,
            .burnout: 5
        ],
        iconImageName: "EnergyDrink"
    )

    static let soylent = GameAction(
        id: "feed_soylent",
        name: "Protein Shake",
        category: .feed,
        description: "Efficient nutrition for efficient people.",
        emoji: "🧴",
        effects: [
            .energy: 15,
            .health: 5,
            .happiness: -5
        ],
        iconImageName: "ProteinShake"
    )

    static let ramen = GameAction(
        id: "feed_ramen",
        name: "Uncrustable",
        category: .feed,
        description: "Classic startup fuel. Cheap and filling.",
        emoji: "🥪",
        effects: [
            .energy: 15,
            .happiness: 5,
            .health: -3
        ],
        iconImageName: "Uncrustable"
    )

    static let doordash = GameAction(
        id: "feed_doordash",
        name: "FoodDash Order",
        category: .feed,
        description: "Convenience at a premium. Burns runway faster.",
        emoji: "📦",
        effects: [
            .energy: 25,
            .happiness: 15,
            .runway: -1
        ],
        iconImageName: "FoodDash"
    )

    static let healthyMeal = GameAction(
        id: "feed_healthy",
        name: "Healthy Meal",
        category: .feed,
        description: "Takes time but worth it for long-term health.",
        emoji: "🥗",
        effects: [
            .energy: 20,
            .health: 15,
            .happiness: 10,
            .burnout: -5
        ],
        cooldownSeconds: 300,
        iconImageName: "HealthyMeal"
    )

    static let teamLunch = GameAction(
        id: "feed_team_lunch",
        name: "Team Lunch",
        category: .feed,
        description: "Bond with the team over food.",
        emoji: "🍕",
        effects: [
            .energy: 15,
            .happiness: 20,
            .social: 15,
            .runway: -2
        ],
        iconImageName: "TeamLunch"
    )
}
