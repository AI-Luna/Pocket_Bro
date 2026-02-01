//
//  SceneManager.swift
//  Pocket Bro
//

import SpriteKit

enum GameSceneType {
    case characterCreation
    case mainGame
    case actionMenu(ActionCategory)
    case gameOver(GameOverReason)
    case victory
    case minigame(MinigameType)
}

final class SceneManager {
    weak var view: SKView?

    private let transitionDuration: TimeInterval = 0.3

    init(view: SKView) {
        self.view = view
    }

    func presentScene(_ sceneType: GameSceneType, transition: SKTransition? = nil) {
        guard let view = view else { return }

        let scene = createScene(for: sceneType)
        scene.scaleMode = .aspectFill

        if let transition = transition {
            view.presentScene(scene, transition: transition)
        } else {
            let defaultTransition = SKTransition.fade(withDuration: transitionDuration)
            view.presentScene(scene, transition: defaultTransition)
        }
    }

    func presentInitialScene() {
        if GameManager.shared.loadGame() {
            if let state = GameManager.shared.state {
                if state.isVictory {
                    presentScene(.victory)
                } else if let reason = state.gameOverReason {
                    presentScene(.gameOver(reason))
                } else {
                    presentScene(.mainGame)
                }
            } else {
                presentScene(.characterCreation)
            }
        } else {
            presentScene(.characterCreation)
        }
    }

    private func createScene(for type: GameSceneType) -> SKScene {
        guard let view = view else {
            fatalError("SceneManager view is nil")
        }

        let size = view.bounds.size

        switch type {
        case .characterCreation:
            return CharacterCreationScene(size: size, sceneManager: self)
        case .mainGame:
            return MainGameScene(size: size, sceneManager: self)
        case .actionMenu(let category):
            return ActionMenuScene(size: size, sceneManager: self, category: category)
        case .gameOver(let reason):
            return GameOverScene(size: size, sceneManager: self, reason: reason)
        case .victory:
            return VictoryScene(size: size, sceneManager: self)
        case .minigame(let type):
            switch type {
            case .dating:
                return DatingMinigameScene(size: size, sceneManager: self)
            case .lockIn:
                return LockInMinigameScene(size: size, sceneManager: self)
            }
        }
    }

    func popToMainGame() {
        presentScene(.mainGame, transition: SKTransition.push(with: .right, duration: transitionDuration))
    }

    func pushActionMenu(category: ActionCategory) {
        presentScene(.actionMenu(category), transition: SKTransition.push(with: .left, duration: transitionDuration))
    }
}
