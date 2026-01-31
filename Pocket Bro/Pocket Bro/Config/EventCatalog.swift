//
//  EventCatalog.swift
//  Pocket Bro
//

import Foundation

final class EventCatalog {
    static let shared = EventCatalog()

    let events: [RandomEvent]

    private init() {
        events = [
            // Positive Events
            RandomEvent(
                id: "event_viral_tweet",
                title: "Viral Tweet!",
                description: "Your hot take about AI went viral. Investors are sliding into your DMs!",
                emoji: "🐦",
                effects: [.funding: 20, .social: 15, .happiness: 10],
                probability: 0.08
            ),
            RandomEvent(
                id: "event_product_hunt",
                title: "Product Hunt Feature!",
                description: "You got featured on Product Hunt! Users are flooding in.",
                emoji: "🚀",
                effects: [.product: 25, .funding: 15, .happiness: 20],
                probability: 0.05,
                minStage: .preSeed
            ),
            RandomEvent(
                id: "event_angel_investor",
                title: "Angel Appears!",
                description: "An angel investor loved your pitch and wants to invest!",
                emoji: "👼",
                effects: [.funding: 40, .runway: 30, .happiness: 25],
                probability: 0.04,
                minStage: .preSeed
            ),
            RandomEvent(
                id: "event_mentor_intro",
                title: "Mentor Introduction",
                description: "A successful founder wants to mentor you!",
                emoji: "🌟",
                effects: [.social: 20, .happiness: 15, .burnout: -10],
                probability: 0.08
            ),
            RandomEvent(
                id: "event_hackathon_win",
                title: "Hackathon Winner!",
                description: "Your team crushed it at the hackathon!",
                emoji: "🏆",
                effects: [.product: 15, .funding: 10, .happiness: 20, .social: 15],
                probability: 0.06
            ),
            RandomEvent(
                id: "event_good_press",
                title: "TechCrunch Coverage",
                description: "TechCrunch wrote a glowing article about your startup!",
                emoji: "📰",
                effects: [.funding: 25, .social: 20, .happiness: 15],
                probability: 0.04,
                minStage: .seed
            ),
            RandomEvent(
                id: "event_flow_state",
                title: "Flow State",
                description: "You hit a perfect flow state. Productivity through the roof!",
                emoji: "🌊",
                effects: [.product: 20, .happiness: 15, .burnout: -5],
                probability: 0.10,
                requiredMood: .happy
            ),

            // Negative Events
            RandomEvent(
                id: "event_server_down",
                title: "Servers Down!",
                description: "Production servers crashed at the worst possible time.",
                emoji: "🔥",
                effects: [.product: -15, .happiness: -20, .burnout: 15],
                probability: 0.08,
                minStage: .preSeed,
                isPositive: false
            ),
            RandomEvent(
                id: "event_competitor_launch",
                title: "Competitor Launches",
                description: "A well-funded competitor just launched something similar.",
                emoji: "😰",
                effects: [.happiness: -15, .burnout: 10],
                probability: 0.07,
                minStage: .seed,
                isPositive: false
            ),
            RandomEvent(
                id: "event_investor_ghost",
                title: "Ghosted by Investor",
                description: "That promising investor stopped responding.",
                emoji: "👻",
                effects: [.happiness: -15, .social: -10, .burnout: 10],
                probability: 0.10,
                minStage: .preSeed,
                isPositive: false
            ),
            RandomEvent(
                id: "event_burnout_warning",
                title: "Burnout Warning",
                description: "Your body is sending warning signs. Maybe slow down?",
                emoji: "⚠️",
                effects: [.health: -10, .happiness: -10],
                probability: 0.15,
                requiredMood: .stressed,
                isPositive: false
            ),
            RandomEvent(
                id: "event_feature_creep",
                title: "Feature Creep",
                description: "Scope creep pushed back your launch date.",
                emoji: "🐛",
                effects: [.product: -10, .burnout: 10, .happiness: -10],
                probability: 0.08,
                isPositive: false
            ),
            RandomEvent(
                id: "event_cofounder_drama",
                title: "Co-founder Tension",
                description: "Disagreements with your co-founder are getting heated.",
                emoji: "😤",
                effects: [.social: -15, .happiness: -15, .burnout: 15],
                probability: 0.06,
                minStage: .seed,
                isPositive: false
            ),
            RandomEvent(
                id: "event_imposter_syndrome",
                title: "Imposter Syndrome",
                description: "Do you really belong here? Doubt creeps in...",
                emoji: "🎭",
                effects: [.happiness: -20, .burnout: 10],
                probability: 0.10,
                isPositive: false
            ),

            // Neutral/Mixed Events
            RandomEvent(
                id: "event_pivot_opportunity",
                title: "Pivot Opportunity",
                description: "User feedback suggests a completely different direction...",
                emoji: "🔄",
                effects: [.product: -5, .happiness: 5, .burnout: 5],
                probability: 0.06,
                minStage: .preSeed
            ),
            RandomEvent(
                id: "event_acquisition_interest",
                title: "Acquisition Interest",
                description: "A big company wants to talk about acquiring you...",
                emoji: "🏢",
                effects: [.happiness: 10, .burnout: 10, .social: 10],
                probability: 0.03,
                minStage: .seriesA
            )
        ]
    }

    func positiveEvents() -> [RandomEvent] {
        events.filter { $0.isPositive }
    }

    func negativeEvents() -> [RandomEvent] {
        events.filter { !$0.isPositive }
    }

    func eventsForStage(_ stage: StartupStage) -> [RandomEvent] {
        events.filter { $0.canTrigger(for: BroState.new(name: "Test", archetype: .bro)) }
    }
}
