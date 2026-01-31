//
//  SocialActions.swift
//  Pocket Bro
//

import Foundation

enum SocialActions {
    static let all: [GameAction] = [
        callFamily,
        coffeeChat,
        founderDinner,
        dating,
        partyTime,
        mentorMeeting
    ]

    static let callFamily = GameAction(
        id: "social_family",
        name: "Call Family",
        category: .social,
        description: "Check in with loved ones. They miss you.",
        emoji: "📞",
        effects: [
            .social: 20,
            .happiness: 15,
            .burnout: -5
        ],
        cooldownSeconds: 300
    )

    static let coffeeChat = GameAction(
        id: "social_coffee",
        name: "Coffee Chat",
        category: .social,
        description: "Casual meetup with a fellow founder.",
        emoji: "☕",
        effects: [
            .social: 15,
            .happiness: 10,
            .energy: 5,
            .funding: 3
        ],
        requirements: [.energy: 10]
    )

    static let founderDinner = GameAction(
        id: "social_dinner",
        name: "Founder Dinner",
        category: .social,
        description: "Network and bond with the startup community.",
        emoji: "🍽️",
        effects: [
            .social: 25,
            .happiness: 20,
            .funding: 10,
            .energy: -10,
            .runway: -2
        ],
        requirements: [.energy: 15],
        minStage: .preSeed
    )

    static let dating = GameAction(
        id: "social_dating",
        name: "Go on a Date",
        category: .social,
        description: "Try to maintain a personal life.",
        emoji: "❤️",
        effects: [
            .social: 30,
            .happiness: 25,
            .energy: -15,
            .burnout: -10
        ],
        requirements: [
            .energy: 20,
            .happiness: 30
        ],
        cooldownSeconds: 900,
        triggersMinigame: .dating
    )

    static let partyTime = GameAction(
        id: "social_party",
        name: "Launch Party",
        category: .social,
        description: "Celebrate milestones with the community!",
        emoji: "🎉",
        effects: [
            .social: 35,
            .happiness: 30,
            .energy: -20,
            .funding: 15,
            .runway: -5
        ],
        requirements: [.energy: 25],
        cooldownSeconds: 1800,
        minStage: .seed
    )

    static let mentorMeeting = GameAction(
        id: "social_mentor",
        name: "Mentor Meeting",
        category: .social,
        description: "Get advice from someone who's been there.",
        emoji: "👨‍🏫",
        effects: [
            .social: 10,
            .happiness: 15,
            .burnout: -10,
            .funding: 5,
            .product: 5
        ],
        requirements: [.energy: 10],
        cooldownSeconds: 600,
        minStage: .preSeed
    )
}
