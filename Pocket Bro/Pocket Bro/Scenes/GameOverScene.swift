//
//  GameOverScene.swift
//  Pocket Bro
//

import SpriteKit

class GameOverScene: BaseGameScene {
    private let reason: GameOverReason

    init(size: CGSize, sceneManager: SceneManager, reason: GameOverReason) {
        self.reason = reason
        super.init(size: size, sceneManager: sceneManager)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var backgroundColor_: SKColor {
        SKColor(red: 0.15, green: 0.05, blue: 0.05, alpha: 1.0)
    }

    override func setupScene() {
        setupBackground()
        setupContent()
        setupButtons()
    }

    private func setupBackground() {
        // Sad gradient overlay
        let overlay = SKSpriteNode(color: SKColor(red: 0.3, green: 0.1, blue: 0.1, alpha: 0.5), size: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = -10
        addChild(overlay)
    }

    private func setupContent() {
        // Game Over title
        let titleLabel = createLabel(text: "GAME OVER", fontSize: 36)
        titleLabel.fontColor = SKColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1.0)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - safeAreaInsets().top - 100)
        addChild(titleLabel)

        // Reason title
        let reasonTitle = createLabel(text: reason.title, fontSize: 24)
        reasonTitle.position = CGPoint(x: size.width / 2, y: titleLabel.position.y - 60)
        addChild(reasonTitle)

        // Reason emoji
        let emoji: String
        switch reason {
        case .burnout: emoji = "🫠"
        case .health: emoji = "🏥"
        case .social: emoji = "😢"
        case .runway: emoji = "💸"
        }

        let emojiLabel = SKLabelNode(text: emoji)
        emojiLabel.fontSize = 80
        emojiLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 20)
        addChild(emojiLabel)

        // Add pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        emojiLabel.run(SKAction.repeatForever(pulse))

        // Message
        let messageLabel = SKLabelNode(text: reason.message)
        messageLabel.fontName = "Menlo"
        messageLabel.fontSize = 14
        messageLabel.fontColor = SKColor(white: 0.7, alpha: 1.0)
        messageLabel.numberOfLines = 0
        messageLabel.preferredMaxLayoutWidth = size.width - 60
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.verticalAlignmentMode = .center
        messageLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 80)
        addChild(messageLabel)

        // Stats summary if available
        if let state = GameManager.shared.state {
            let statsText = """
            Days Survived: \(90 - state.startup.runway)
            Stage Reached: \(state.startup.stage.displayName)
            Actions Taken: \(state.totalActionsPerformed)
            """

            let statsLabel = SKLabelNode(text: statsText)
            statsLabel.fontName = "Menlo"
            statsLabel.fontSize = 12
            statsLabel.fontColor = SKColor(white: 0.5, alpha: 1.0)
            statsLabel.numberOfLines = 3
            statsLabel.horizontalAlignmentMode = .center
            statsLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 160)
            addChild(statsLabel)
        }
    }

    private func setupButtons() {
        // Try Again button
        let tryAgainButton = PixelButtonNode(text: "Try Again", icon: "🔄", size: CGSize(width: 180, height: 50))
        tryAgainButton.position = CGPoint(x: size.width / 2, y: safeAreaInsets().bottom + 120)

        tryAgainButton.onTap = { [weak self] in
            GameManager.shared.deleteGame()
            self?.sceneManager?.presentScene(.characterCreation)
        }

        addChild(tryAgainButton)

        // Quit button
        let quitButton = PixelButtonNode(text: "Quit", size: CGSize(width: 120, height: 40))
        quitButton.position = CGPoint(x: size.width / 2, y: safeAreaInsets().bottom + 60)

        quitButton.onTap = {
            // In a real app, this might go to a main menu
            exit(0)
        }

        addChild(quitButton)
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        // Fade in effect
        alpha = 0
        run(SKAction.fadeIn(withDuration: 0.5))
    }
}
