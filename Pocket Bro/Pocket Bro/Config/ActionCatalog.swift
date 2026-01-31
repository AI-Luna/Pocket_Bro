//
//  ActionCatalog.swift
//  Pocket Bro
//

import Foundation

final class ActionCatalog {
    static let shared = ActionCatalog()

    private(set) var allActions: [GameAction] = []

    private init() {
        allActions = FeedingActions.all + WorkActions.all + SelfCareActions.all + SocialActions.all
    }

    func actions(for category: ActionCategory) -> [GameAction] {
        allActions.filter { $0.category == category }
    }

    func action(byId id: String) -> GameAction? {
        allActions.first { $0.id == id }
    }

    func availableActions(for state: BroState) -> [GameAction] {
        allActions.filter { $0.canPerform(with: state) }
    }

    func availableActions(for state: BroState, in category: ActionCategory) -> [GameAction] {
        actions(for: category).filter { $0.canPerform(with: state) }
    }
}
