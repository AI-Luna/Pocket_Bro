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

    private let dialogues: [ActionCategory: [String]] = [
        .feed: [
            "Mmm, fuel for coding!",
            "Brain food acquired.",
            "Carbs loading...",
            "This'll keep me going!",
            "Delicious productivity boost!"
        ],
        .work: [
            "Shipping features!",
            "Code goes brrrr...",
            "10x developer mode!",
            "Building the future!",
            "Another PR merged!"
        ],
        .selfCare: [
            "Recharging batteries...",
            "Self-care is important!",
            "Feeling refreshed!",
            "Balance is key.",
            "Taking a breather."
        ],
        .social: [
            "Networking is everything!",
            "Made a new connection!",
            "Building relationships.",
            "Community matters!",
            "Great conversation!"
        ]
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
        let dialogue = randomDialogue(for: action.category)

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

    private func randomDialogue(for category: ActionCategory) -> String {
        dialogues[category]?.randomElement() ?? "Done!"
    }
}
