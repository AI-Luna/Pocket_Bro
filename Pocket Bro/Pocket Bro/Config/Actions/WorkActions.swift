//
//  WorkActions.swift
//  Pocket Bro
//

import Foundation

// Work icon indices in sprite sheet (3 cols x 2 rows):
// 0: Laptop  1: Brain  2: Handshake
// 3: Microphone  4: Briefcase  5: Lock

enum WorkActions {
    static let all: [GameAction] = [
        grind,
        deepWork,
        networking,
        pitchPractice,
        investorMeeting,
        lockIn
    ]

    static let grind = GameAction(
        id: "work_grind",
        name: "Grind Session",
        category: .work,
        description: "Put in the work. Progress the product.",
        emoji: "💻",
        effects: [
            .energy: -15,
            .product: 10,
            .burnout: 10,
            .happiness: -5
        ],
        workIconIndex: 0
    )

    static let deepWork = GameAction(
        id: "work_deep",
        name: "Deep Work",
        category: .work,
        description: "Focused, uninterrupted productivity. High output.",
        emoji: "🧠",
        effects: [
            .energy: -25,
            .product: 25,
            .burnout: 15,
            .social: -5
        ],
        cooldownSeconds: 600,
        workIconIndex: 1
    )

    static let networking = GameAction(
        id: "work_network",
        name: "Networking Event",
        category: .work,
        description: "Schmooze with fellow founders and investors.",
        emoji: "🤝",
        effects: [
            .energy: -10,
            .funding: 5,
            .social: 20,
            .burnout: 5
        ],
        workIconIndex: 2
    )

    static let pitchPractice = GameAction(
        id: "work_pitch",
        name: "Practice Pitch",
        category: .work,
        description: "Rehearse your startup pitch. Builds funding potential.",
        emoji: "🎤",
        effects: [
            .energy: -10,
            .funding: 8,
            .happiness: -5,
            .burnout: 5
        ],
        workIconIndex: 3
    )

    static let investorMeeting = GameAction(
        id: "work_investor",
        name: "Investor Meeting",
        category: .work,
        description: "Big opportunity! Requires good stats to succeed.",
        emoji: "💼",
        effects: [
            .energy: -20,
            .funding: 30,
            .burnout: 10,
            .happiness: 10
        ],
        cooldownSeconds: 900,
        workIconIndex: 4
    )

    static let lockIn = GameAction(
        id: "work_lockin",
        name: "Lock In Mode",
        category: .work,
        description: "Extreme focus session. Massive gains, massive cost.",
        emoji: "🔒",
        effects: [
            .energy: -40,
            .product: 50,
            .burnout: 25,
            .health: -10,
            .social: -10
        ],
        cooldownSeconds: 1800,
        triggersMinigame: .lockIn,
        workIconIndex: 5
    )
}
