//
//  ActionExecutor.swift
//  Pocket Bro
//

import Foundation

protocol ActionExecutorDelegate: AnyObject {
    func actionExecutor(_ executor: ActionExecutor, didExecute result: ActionResult)
    func actionExecutor(_ executor: ActionExecutor, didFailAction action: GameAction, reason: String)
}

final class ActionExecutor {
    weak var delegate: ActionExecutorDelegate?

    private var cooldowns: [String: Date] = [:]
    private let persistence: PersistenceService

    private let actionDialogues: [String: [String]] = [
        // MARK: Feed
        "feed_energy_drink": [
            "Caffeine kicking in!",
            "Wired and ready to code.",
            "Tastes like productivity.",
            "That's the good stuff!",
            "Buzz mode activated."
        ],
        "feed_soylent": [
            "Efficient nutrition loaded.",
            "400 calories of optimization.",
            "Fuel for the grind.",
            "Not tasty, but effective.",
            "Macro goals: crushed."
        ],
        "feed_ramen": [
            "Classic founder fuel!",
            "Simple but hits the spot.",
            "PB&J never fails.",
            "Childhood vibes.",
            "Quick and easy, just how I like it."
        ],
        "feed_doordash": [
            "Delivery in 20 minutes!",
            "Treating myself today.",
            "Worth every penny.",
            "Time saved = code shipped.",
            "The convenience economy works!"
        ],
        "feed_healthy": [
            "My body thanks me.",
            "Greens for the win!",
            "Investing in long-term health.",
            "Fuel that actually fuels.",
            "Clean eating, clear thinking."
        ],
        "feed_team_lunch": [
            "Team bonding over burritos!",
            "Best ideas come over lunch.",
            "Nothing beats a team meal.",
            "Food brings people together.",
            "Lunch meetings > Zoom meetings."
        ],
        // MARK: Work
        "work_grind": [
            "Shipping features!",
            "Code goes brrrr...",
            "One commit at a time.",
            "The grind never stops.",
            "Progress is progress!"
        ],
        "work_deep": [
            "In the zone. Don't disturb.",
            "Flow state achieved.",
            "Pure focus, maximum output.",
            "This is where magic happens.",
            "3 hours felt like 30 minutes."
        ],
        "work_network": [
            "Swapped cards with a VC!",
            "Connections are currency.",
            "Met some cool founders!",
            "Expanding the network.",
            "You never know who you'll meet."
        ],
        "work_pitch": [
            "Pitch getting sharper!",
            "Nailed the value prop.",
            "Practice makes funded.",
            "One step closer to demo day.",
            "Storytelling is a superpower."
        ],
        "work_investor": [
            "They seemed interested!",
            "Big meeting energy.",
            "Term sheet incoming?!",
            "Crushed that presentation.",
            "Follow-up email sent!"
        ],
        "work_lockin": [
            "LOCKED IN. No distractions.",
            "Absolute beast mode.",
            "Sleep is for Series B.",
            "Built different today.",
            "Shipped a week's worth of work."
        ],
        // MARK: Self-Care
        "care_nap": [
            "Quick recharge complete.",
            "Power nap = power move.",
            "20 minutes well spent.",
            "Zzz... okay I'm back!",
            "Naps are a life hack."
        ],
        "care_meditate": [
            "Inner peace restored.",
            "Mind is clear now.",
            "Namaste, stress. Goodbye.",
            "Centered and focused.",
            "Meditation is my secret weapon."
        ],
        "care_exercise": [
            "Gains for days!",
            "Endorphins are flowing.",
            "Healthy body, sharp mind.",
            "Crushed that workout!",
            "Gym therapy hits different."
        ],
        "care_therapy": [
            "Feeling heard and understood.",
            "Mental health is real wealth.",
            "Breakthroughs happening.",
            "Everyone needs someone to talk to.",
            "Best investment I make."
        ],
        "care_vacation": [
            "I needed this so badly.",
            "Recharging the whole system.",
            "Touch grass? I became grass.",
            "Coming back stronger.",
            "Remember: rest is productive."
        ],
        "care_sleep": [
            "8 full hours. Legendary.",
            "Woke up feeling human!",
            "Sleep debt: paid off.",
            "Dreams were wild last night.",
            "This is what rest feels like?!"
        ],
        // MARK: Social
        "social_family": [
            "Mom says hi!",
            "Family always grounds me.",
            "They're so proud of me.",
            "Needed to hear their voice.",
            "Home is where the WiFi is."
        ],
        "social_coffee": [
            "Great chat over lattes!",
            "Coffee + conversation = magic.",
            "Love swapping founder stories.",
            "Caffeine and community!",
            "Found my new accountability buddy."
        ],
        "social_dinner": [
            "Incredible dinner conversation!",
            "Founders who eat together...",
            "The food was amazing!",
            "New collab ideas brewing.",
            "Ate way too much. Worth it."
        ],
        "social_dating": [
            "Butterflies in my stomach!",
            "They actually laughed at my jokes!",
            "Is this what work-life balance is?",
            "Trying to be normal for once.",
            "They asked about my startup..."
        ],
        "social_party": [
            "What a night!",
            "Celebrated in style!",
            "Party mode: activated.",
            "Memories made tonight!",
            "The startup scene knows how to party."
        ],
        "social_mentor": [
            "Wisdom unlocked!",
            "Learned so much today.",
            "Mentors change everything.",
            "Taking notes furiously.",
            "They've seen it all before."
        ]
    ]

    private let categoryFallbackDialogues: [ActionCategory: [String]] = [
        .feed: ["Mmm, fuel for coding!", "Brain food acquired.", "That hit the spot!"],
        .work: ["Building the future!", "Another PR merged!", "Shipping!"],
        .selfCare: ["Feeling refreshed!", "Balance is key.", "Taking care of me."],
        .social: ["Good times!", "People make life better.", "Feeling connected."]
    ]

    init(persistence: PersistenceService) {
        self.persistence = persistence
        self.cooldowns = persistence.loadActionCooldowns()
    }

    func execute(action: GameAction, state: inout BroState) -> ActionResult? {
        guard action.canPerform(with: state) else {
            let reason = action.reasonCantPerform(with: state) ?? "Cannot perform this action"
            delegate?.actionExecutor(self, didFailAction: action, reason: reason)
            return nil
        }

        if isOnCooldown(action: action) {
            let remaining = cooldownRemaining(for: action)
            let reason = "On cooldown for \(Int(remaining))s"
            delegate?.actionExecutor(self, didFailAction: action, reason: reason)
            return nil
        }

        state.applyEffects(action.effects)
        state.totalActionsPerformed += 1
        state.lastPlayedAt = Date()

        if action.cooldownSeconds > 0 {
            setCooldown(for: action)
        }

        let stageAdvanced = state.startup.tryAdvanceStage()
        let dialogue = randomDialogue(for: action)

        let result = ActionResult(
            action: action,
            effectsApplied: action.effects,
            dialogue: dialogue,
            triggeredEvent: nil,
            stageAdvanced: stageAdvanced
        )

        delegate?.actionExecutor(self, didExecute: result)
        return result
    }

    func isOnCooldown(action: GameAction) -> Bool {
        guard action.cooldownSeconds > 0,
              let lastUsed = cooldowns[action.id] else { return false }
        return Date().timeIntervalSince(lastUsed) < action.cooldownSeconds
    }

    func cooldownRemaining(for action: GameAction) -> TimeInterval {
        guard action.cooldownSeconds > 0,
              let lastUsed = cooldowns[action.id] else { return 0 }
        let elapsed = Date().timeIntervalSince(lastUsed)
        return max(0, action.cooldownSeconds - elapsed)
    }

    private func setCooldown(for action: GameAction) {
        cooldowns[action.id] = Date()
        persistence.saveActionCooldowns(cooldowns)
    }

    func clearExpiredCooldowns() {
        let now = Date()
        cooldowns = cooldowns.filter { (actionId, lastUsed) in
            guard let action = ActionCatalog.shared.action(byId: actionId) else { return false }
            return now.timeIntervalSince(lastUsed) < action.cooldownSeconds
        }
        persistence.saveActionCooldowns(cooldowns)
    }

    private func randomDialogue(for action: GameAction) -> String {
        if let lines = actionDialogues[action.id], let line = lines.randomElement() {
            return line
        }
        return categoryFallbackDialogues[action.category]?.randomElement() ?? "Done!"
    }
}
