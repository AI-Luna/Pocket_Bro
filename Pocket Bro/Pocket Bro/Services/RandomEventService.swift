//
//  RandomEventService.swift
//  Pocket Bro
//

import Foundation

protocol RandomEventServiceDelegate: AnyObject {
    func eventService(_ service: RandomEventService, didTrigger event: RandomEvent)
}

final class RandomEventService {
    weak var delegate: RandomEventServiceDelegate?

    private var recentEventIds: Set<String> = []
    private let maxRecentEvents = 10

    func checkForEvent(state: BroState, afterAction action: GameAction) -> RandomEvent? {
        let eligibleEvents = EventCatalog.shared.events.filter { event in
            event.canTrigger(for: state) &&
            !recentEventIds.contains(event.id) &&
            Double.random(in: 0...1) < event.probability
        }

        guard let event = eligibleEvents.randomElement() else { return nil }

        trackEvent(event)
        delegate?.eventService(self, didTrigger: event)
        return event
    }

    func checkForRandomEvent(state: BroState) -> RandomEvent? {
        let eligibleEvents = EventCatalog.shared.events.filter { event in
            event.canTrigger(for: state) &&
            !recentEventIds.contains(event.id)
        }

        guard let event = eligibleEvents.randomElement(),
              Double.random(in: 0...1) < event.probability else { return nil }

        trackEvent(event)
        delegate?.eventService(self, didTrigger: event)
        return event
    }

    private func trackEvent(_ event: RandomEvent) {
        recentEventIds.insert(event.id)
        if recentEventIds.count > maxRecentEvents {
            recentEventIds.removeFirst()
        }
    }

    func resetRecentEvents() {
        recentEventIds.removeAll()
    }
}
