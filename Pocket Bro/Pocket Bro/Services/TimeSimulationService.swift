//
//  TimeSimulationService.swift
//  Pocket Bro
//

import Foundation

struct TimeSimulationConfig {
    let decayIntervalSeconds: TimeInterval = 60
    let maxSimulatedHours: Double = 72

    let decayRates: [StatType: Double] = [
        .energy: -1.0,
        .health: -0.2,
        .happiness: -0.5,
        .social: -0.3,
        .burnout: 0.1
    ]

    let runwayDecayPerDay: Int = 1
}

final class TimeSimulationService {
    private let config = TimeSimulationConfig()
    private let persistence: PersistenceService

    init(persistence: PersistenceService) {
        self.persistence = persistence
    }

    func simulateElapsedTime(state: inout BroState, from lastTime: Date, to currentTime: Date) {
        let elapsedSeconds = currentTime.timeIntervalSince(lastTime)

        guard elapsedSeconds > 0 else { return }

        let maxSeconds = config.maxSimulatedHours * 3600
        let simulatedSeconds = min(elapsedSeconds, maxSeconds)

        let intervals = Int(simulatedSeconds / config.decayIntervalSeconds)

        guard intervals > 0 else { return }

        for (stat, rate) in config.decayRates {
            let totalDecay = Int(rate * Double(intervals))
            state.stats[stat] = state.stats[stat] + totalDecay
        }

        let daysElapsed = Int(simulatedSeconds / 86400)
        if daysElapsed > 0 {
            state.startup.runway -= daysElapsed * config.runwayDecayPerDay
        }

        state.lastPlayedAt = currentTime
    }

    func applyGameLoopDecay(state: inout BroState) {
        for (stat, rate) in config.decayRates {
            let decay = Int(rate)
            if decay != 0 {
                state.stats[stat] = state.stats[stat] + decay
            }
        }
    }

    func shouldDecayRunway(lastDecay: Date, currentTime: Date) -> Bool {
        let calendar = Calendar.current
        return !calendar.isDate(lastDecay, inSameDayAs: currentTime)
    }
}
