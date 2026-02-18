//
//  StatNotificationManager.swift
//  Pocket Bro
//

import Foundation
import UserNotifications

// MARK: - Stat Zone

enum StatZone: String {
    case green, orange, red

    init(value: Int) {
        if value < 20 { self = .red }
        else if value < 40 { self = .orange }
        else { self = .green }
    }
}

// MARK: - Manager

final class StatNotificationManager {
    static let shared = StatNotificationManager()

    private let monitoredStats: [StatType] = [.energy, .health, .happiness, .social]
    private var previousZones: [StatType: StatZone] = [:]

    // Decay per minute from TimeSimulationConfig
    private let decayPerMinute: [StatType: Double] = [
        .energy:    1.0,
        .health:    0.2,
        .happiness: 0.5,
        .social:    0.3
    ]

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onGameStateUpdate(_:)),
            name: .gameStateDidUpdate,
            object: nil
        )
    }

    // MARK: - Permission

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // MARK: - Foreground zone-transition detection

    @objc private func onGameStateUpdate(_ notification: Notification) {
        guard let state = notification.object as? BroState else { return }

        for stat in monitoredStats {
            let value = state.stats[stat]
            let newZone = StatZone(value: value)
            let oldZone = previousZones[stat] ?? StatZone(value: value) // init silently

            if oldZone == .green && (newZone == .orange || newZone == .red) {
                fireImmediateNotification(stat: stat, zone: newZone, name: state.name)
            } else if oldZone == .orange && newZone == .red {
                fireImmediateNotification(stat: stat, zone: .red, name: state.name)
            }

            previousZones[stat] = newZone
        }
    }

    // MARK: - Background scheduling (call on app background)

    func scheduleBackgroundNotifications(state: BroState) {
        cancelBackgroundNotifications()

        for stat in monitoredStats {
            guard let rate = decayPerMinute[stat], rate > 0 else { continue }
            let value = state.stats[stat]

            // Orange (crossing below 40)
            if value > 40 {
                let delay = Double(value - 40) / rate * 60
                schedule(id: "bg_orange_\(stat.rawValue)", stat: stat, zone: .orange,
                         name: state.name, delay: delay)
            }

            // Red (crossing below 20)
            if value > 20 {
                let delay = Double(value - 20) / rate * 60
                schedule(id: "bg_red_\(stat.rawValue)", stat: stat, zone: .red,
                         name: state.name, delay: delay)
            }
        }
    }

    func cancelBackgroundNotifications() {
        let ids = monitoredStats.flatMap {
            ["bg_orange_\($0.rawValue)", "bg_red_\($0.rawValue)"]
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: - Daily morning / night reminders

    func scheduleDailyNotifications(name: String) {
        cancelDailyNotifications()

        scheduleDaily(id: "daily_morning", hour: 9, minute: 0,
                      title: morningTitle(), body: morningBody(name: name))
        scheduleDaily(id: "daily_night", hour: 22, minute: 0,
                      title: nightTitle(), body: nightBody(name: name))
    }

    func cancelDailyNotifications() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["daily_morning", "daily_night"])
    }

    private func scheduleDaily(id: String, hour: Int, minute: Int, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Daily copy

    private func morningTitle() -> String {
        let pool = [
            "☀️ Rise and Grind",
            "🌅 Another Day, Another Deploy",
            "☕ Good Morning, Founder",
            "🚀 Morning Standup Time"
        ]
        return pool.randomElement()!
    }

    private func morningBody(name: String) -> String {
        let pool = [
            "\(name) is booting up. Make sure they eat something before opening Slack.",
            "New day, new PRs. Check in on \(name) before the grind takes over.",
            "\(name)'s ready to disrupt. Keep their energy and health topped off.",
            "Good morning! \(name) won't take care of themselves — that's your job.",
            "The market's open and \(name) is already stressed. Start the day right."
        ]
        return pool.randomElement()!
    }

    private func nightTitle() -> String {
        let pool = [
            "🌙 Ship It and Sleep",
            "😴 Shut the Laptop, \("Bro")",
            "🌃 EOD Check-In",
            "💤 Time to Decompress"
        ]
        return pool.randomElement()!
    }

    private func nightBody(name: String) -> String {
        let pool = [
            "Did \(name) actually rest today? Log off and recharge before tomorrow's chaos.",
            "The PRs can wait. Make sure \(name) winds down before burnout kicks in.",
            "\(name) survived another day. Don't forget to feed them and put them to bed.",
            "Closing time for \(name). Check their stats before calling it a night.",
            "Even the best founders need sleep. Tuck \(name) in before you do."
        ]
        return pool.randomElement()!
    }

    // MARK: - Helpers

    private func fireImmediateNotification(stat: StatType, zone: StatZone, name: String) {
        let content = makeContent(stat: stat, zone: zone, name: name)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let id = "fg_\(stat.rawValue)_\(zone.rawValue)_\(Date().timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func schedule(id: String, stat: StatType, zone: StatZone, name: String, delay: TimeInterval) {
        guard delay > 60 else { return } // skip if less than a minute away
        let content = makeContent(stat: stat, zone: zone, name: name)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func makeContent(stat: StatType, zone: StatZone, name: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title(stat: stat, zone: zone)
        content.body = body(stat: stat, zone: zone, name: name)
        content.sound = .default
        return content
    }

    // MARK: - Copy

    private func title(stat: StatType, zone: StatZone) -> String {
        switch (stat, zone) {
        case (.energy,    .orange): return "⚡️ Energy Fading"
        case (.energy,    .red):    return "🪫 Energy Critical"
        case (.health,    .orange): return "🤒 Health Dropping"
        case (.health,    .red):    return "🚑 Health Critical"
        case (.happiness, .orange): return "😐 Vibes Off"
        case (.happiness, .red):    return "😔 Founder Spiraling"
        case (.social,    .orange): return "👻 Going Ghost"
        case (.social,    .red):    return "🏝️ Full Hermit Mode"
        default:                    return "⚠️ Check on Your Founder"
        }
    }

    private func body(stat: StatType, zone: StatZone, name: String) -> String {
        let pool: [String]
        switch (stat, zone) {
        case (.energy, .orange):
            pool = [
                "\(name)'s running on fumes. The grind is officially winning.",
                "Skipping sleep again? \(name)'s energy is tanking fast.",
                "Red Bull count: ∞. Sleep count: 0. Not looking great for \(name)."
            ]
        case (.energy, .red):
            pool = [
                "\(name) just fell asleep at their keyboard. Classic founder moment.",
                "Your founder is basically a zombie rn. Feed them something.",
                "Energy: redlined. \(name) needs rest before they fully crash out."
            ]
        case (.health, .orange):
            pool = [
                "3 weeks of ramen caught up with \(name). Health is dropping.",
                "\(name) keeps skipping gym day. The startup grind is winning.",
                "Hustle culture 1, \(name)'s body 0. Time to actually take a break."
            ]
        case (.health, .red):
            pool = [
                "\(name) is literally falling apart. Stress-induced everything.",
                "Your founder is running on willpower alone. Health is critical.",
                "\(name) needs a doctor, not another standup. Health is in the red."
            ]
        case (.happiness, .orange):
            pool = [
                "\(name) is giving founder depression energy. Check on them.",
                "The vibe is off. \(name) needs a win — or at least a nap.",
                "Morale dropping. The rejection emails are really stacking up."
            ]
        case (.happiness, .red):
            pool = [
                "\(name) has not touched grass in weeks. They are not okay.",
                "Full spiral mode. \(name) needs some good news ASAP.",
                "When's the last time \(name) smiled? Happiness: critical."
            ]
        case (.social, .orange):
            pool = [
                "\(name) has been ghosting everyone. Maybe send them outside.",
                "Last seen: texting investors at 2am. \(name)'s social battery is dying.",
                "\(name) is turning into a solo founder hermit. Not a good sign."
            ]
        case (.social, .red):
            pool = [
                "\(name)'s only friends are their Jira tickets now. Seek human contact.",
                "Full hermit mode activated. \(name) hasn't talked to a human in days.",
                "Social life: nonexistent. \(name) needs IRL interaction immediately."
            ]
        default:
            pool = ["Your founder needs some attention."]
        }
        return pool.randomElement() ?? pool[0]
    }
}
