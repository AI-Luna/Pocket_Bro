//
//  UserDefaultsPersistence.swift
//  Pocket Bro
//

import Foundation

protocol PersistenceService {
    func save(_ state: BroState)
    func load() -> BroState?
    func delete()
    func saveLastBackgroundTime(_ date: Date)
    func loadLastBackgroundTime() -> Date?
    func saveActionCooldowns(_ cooldowns: [String: Date])
    func loadActionCooldowns() -> [String: Date]
}

final class UserDefaultsPersistence: PersistenceService {
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let broState = "pocket_bro_state"
        static let lastBackgroundTime = "pocket_bro_last_background"
        static let actionCooldowns = "pocket_bro_cooldowns"
    }

    func save(_ state: BroState) {
        do {
            let data = try JSONEncoder().encode(state)
            defaults.set(data, forKey: Keys.broState)
        } catch {
            print("Failed to save BroState: \(error)")
        }
    }

    func load() -> BroState? {
        guard let data = defaults.data(forKey: Keys.broState) else { return nil }
        do {
            return try JSONDecoder().decode(BroState.self, from: data)
        } catch {
            print("Failed to load BroState: \(error)")
            return nil
        }
    }

    func delete() {
        defaults.removeObject(forKey: Keys.broState)
        defaults.removeObject(forKey: Keys.lastBackgroundTime)
        defaults.removeObject(forKey: Keys.actionCooldowns)
    }

    func saveLastBackgroundTime(_ date: Date) {
        defaults.set(date, forKey: Keys.lastBackgroundTime)
    }

    func loadLastBackgroundTime() -> Date? {
        defaults.object(forKey: Keys.lastBackgroundTime) as? Date
    }

    func saveActionCooldowns(_ cooldowns: [String: Date]) {
        do {
            let data = try JSONEncoder().encode(cooldowns)
            defaults.set(data, forKey: Keys.actionCooldowns)
        } catch {
            print("Failed to save cooldowns: \(error)")
        }
    }

    func loadActionCooldowns() -> [String: Date] {
        guard let data = defaults.data(forKey: Keys.actionCooldowns) else { return [:] }
        do {
            return try JSONDecoder().decode([String: Date].self, from: data)
        } catch {
            print("Failed to load cooldowns: \(error)")
            return [:]
        }
    }
}
