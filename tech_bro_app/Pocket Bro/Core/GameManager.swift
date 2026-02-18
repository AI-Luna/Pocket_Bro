//
//  GameManager.swift
//  Pocket Bro
//

import Foundation

extension Notification.Name {
    static let gameStateDidUpdate = Notification.Name("gameStateDidUpdate")
    static let gameDidEnd = Notification.Name("gameDidEnd")
    static let stageDidAdvance = Notification.Name("stageDidAdvance")
    static let eventDidTrigger = Notification.Name("eventDidTrigger")
}

final class GameManager {
    static let shared = GameManager()

    private(set) var state: BroState?
    private let persistence: PersistenceService
    private let timeSimulation: TimeSimulationService
    private let actionExecutor: ActionExecutor
    private let eventService: RandomEventService

    private var gameLoopTimer: Timer?
    private let gameLoopInterval: TimeInterval = 60

    var hasActiveGame: Bool {
        state != nil && !(state?.isGameOver ?? true) && !(state?.isVictory ?? false)
    }

    private init() {
        self.persistence = UserDefaultsPersistence()
        self.timeSimulation = TimeSimulationService(persistence: persistence)
        self.actionExecutor = ActionExecutor(persistence: persistence)
        self.eventService = RandomEventService()
    }

    // MARK: - Game Lifecycle

    func loadGame() -> Bool {
        guard let savedState = persistence.load() else { return false }
        self.state = savedState

        if let lastBackground = persistence.loadLastBackgroundTime() {
            simulateElapsedTime(from: lastBackground)
        }

        StatNotificationManager.shared.scheduleDailyNotifications(name: savedState.name)
        startGameLoop()
        notifyStateUpdate()
        return true
    }

    func newGame(name: String, archetype: Archetype, city: City = .sanFrancisco) {
        state = BroState.new(name: name, archetype: archetype, city: city)
        saveGame()
        StatNotificationManager.shared.scheduleDailyNotifications(name: name)
        startGameLoop()
        notifyStateUpdate()
    }

    func updateArchetype(_ archetype: Archetype) {
        guard var currentState = state else { return }
        currentState.archetype = archetype
        state = currentState
        saveGame()
        notifyStateUpdate()
    }

    func updateName(_ name: String) {
        guard var currentState = state else { return }
        currentState.name = name
        state = currentState
        saveGame()
        notifyStateUpdate()
    }

    func updateCity(_ city: City) {
        guard var currentState = state else { return }
        currentState.city = city
        state = currentState
        saveGame()
        notifyStateUpdate()
    }

    func saveGame() {
        guard let state = state else { return }
        persistence.save(state)
    }

    func deleteGame() {
        stopGameLoop()
        StatNotificationManager.shared.cancelDailyNotifications()
        state = nil
        persistence.delete()
    }

    func resetAllData() {
        stopGameLoop()
        StatNotificationManager.shared.cancelDailyNotifications()
        state = nil
        persistence.delete()
        persistence.clearOnboardingComplete()
    }

    // MARK: - Actions

    func performAction(_ action: GameAction) -> ActionResult? {
        guard var currentState = state else { return nil }

        let result = actionExecutor.execute(action: action, state: &currentState)

        if let result = result {
            state = currentState

            if let event = eventService.checkForEvent(state: currentState, afterAction: action) {
                state?.applyEffects(event.effects)
                state?.eventsExperienced.append(event.id)
                NotificationCenter.default.post(name: .eventDidTrigger, object: event)
            }

            if result.stageAdvanced {
                NotificationCenter.default.post(name: .stageDidAdvance, object: state?.startup.stage)
            }

            checkGameEndConditions()
            saveGame()
            notifyStateUpdate()
        }

        return result
    }

    func canPerformAction(_ action: GameAction) -> Bool {
        guard let state = state else { return false }
        return action.canPerform(with: state) && !actionExecutor.isOnCooldown(action: action)
    }

    func cooldownRemaining(for action: GameAction) -> TimeInterval {
        actionExecutor.cooldownRemaining(for: action)
    }

    // MARK: - Game Loop

    private func startGameLoop() {
        stopGameLoop()
        gameLoopTimer = Timer.scheduledTimer(withTimeInterval: gameLoopInterval, repeats: true) { [weak self] _ in
            self?.gameLoopTick()
        }
    }

    private func stopGameLoop() {
        gameLoopTimer?.invalidate()
        gameLoopTimer = nil
    }

    private func gameLoopTick() {
        guard var currentState = state, !currentState.isGameOver, !currentState.isVictory else {
            stopGameLoop()
            return
        }

        timeSimulation.applyGameLoopDecay(state: &currentState)
        state = currentState

        if let event = eventService.checkForRandomEvent(state: currentState) {
            state?.applyEffects(event.effects)
            state?.eventsExperienced.append(event.id)
            NotificationCenter.default.post(name: .eventDidTrigger, object: event)
        }

        checkGameEndConditions()
        saveGame()
        notifyStateUpdate()
    }

    // MARK: - Time Simulation

    func appWillEnterBackground() {
        persistence.saveLastBackgroundTime(Date())
        saveGame()
        stopGameLoop()
        if let state = state {
            StatNotificationManager.shared.scheduleBackgroundNotifications(state: state)
        }
    }

    func appDidEnterForeground() {
        StatNotificationManager.shared.cancelBackgroundNotifications()
        if let lastBackground = persistence.loadLastBackgroundTime() {
            simulateElapsedTime(from: lastBackground)
        }
        if let name = state?.name {
            StatNotificationManager.shared.scheduleDailyNotifications(name: name)
        }
        startGameLoop()
        notifyStateUpdate()
    }

    private func simulateElapsedTime(from lastTime: Date) {
        guard var currentState = state else { return }
        timeSimulation.simulateElapsedTime(state: &currentState, from: lastTime, to: Date())
        state = currentState
        checkGameEndConditions()
        saveGame()
    }

    // MARK: - Game End Conditions

    private func checkGameEndConditions() {
        guard let currentState = state else { return }

        if currentState.isVictory {
            stopGameLoop()
            NotificationCenter.default.post(name: .gameDidEnd, object: ["victory": true])
        } else if let reason = currentState.gameOverReason {
            stopGameLoop()
            NotificationCenter.default.post(name: .gameDidEnd, object: ["reason": reason])
        }
    }

    // MARK: - Notifications

    private func notifyStateUpdate() {
        NotificationCenter.default.post(name: .gameStateDidUpdate, object: state)
    }
}
