//
//  SelfCareActions.swift
//  Pocket Bro
//

import Foundation

// Self-care icon indices in sprite sheet (3 cols x 2 rows):
// 0: Sleep Mask  1: Lotus Flower  2: Mountain/Nature
// 3: Dumbbells  4: Therapy Couch  5: Bed with Moon

enum SelfCareActions {
    static let all: [GameAction] = [
        powerNap,
        meditation,
        exercise,
        therapySession,
        vacation,
        sleepFull
    ]

    static let powerNap = GameAction(
        id: "care_nap",
        name: "Power Nap",
        category: .selfCare,
        description: "Quick 20-minute recharge.",
        emoji: "😴",
        effects: [
            .energy: 25,
            .burnout: -5
        ],
        selfCareIconIndex: 0,
        isPremium: false  // Free action
    )

    static let meditation = GameAction(
        id: "care_meditate",
        name: "Meditation",
        category: .selfCare,
        description: "Center yourself. Reduce stress.",
        emoji: "🧘",
        effects: [
            .burnout: -15,
            .happiness: 10,
            .health: 5
        ],
        cooldownSeconds: 300,
        selfCareIconIndex: 1,
        isPremium: true
    )

    static let exercise = GameAction(
        id: "care_exercise",
        name: "Gym Session",
        category: .selfCare,
        description: "Healthy body, healthy mind.",
        emoji: "🏋️",
        effects: [
            .energy: -10,
            .health: 20,
            .happiness: 15,
            .burnout: -10
        ],
        cooldownSeconds: 600,
        selfCareIconIndex: 3,
        isPremium: true
    )

    static let therapySession = GameAction(
        id: "care_therapy",
        name: "Therapy Session",
        category: .selfCare,
        description: "Professional mental health support.",
        emoji: "🛋️",
        effects: [
            .burnout: -25,
            .happiness: 20,
            .social: 5,
            .runway: -1
        ],
        cooldownSeconds: 900,
        selfCareIconIndex: 4,
        isPremium: true
    )

    static let vacation = GameAction(
        id: "care_vacation",
        name: "Mini Vacation",
        category: .selfCare,
        description: "Sometimes you need to step away completely.",
        emoji: "🏖️",
        effects: [
            .energy: 40,
            .health: 20,
            .happiness: 30,
            .burnout: -40,
            .runway: -5
        ],
        cooldownSeconds: 3600,
        selfCareIconIndex: 2,
        isPremium: true
    )

    static let sleepFull = GameAction(
        id: "care_sleep",
        name: "8-Hr Sleep",
        category: .selfCare,
        description: "8 hours of quality sleep. A luxury for founders.",
        emoji: "🌙",
        effects: [
            .energy: 50,
            .health: 15,
            .burnout: -20,
            .happiness: 10
        ],
        cooldownSeconds: 600,
        selfCareIconIndex: 5,
        isPremium: true
    )
}
