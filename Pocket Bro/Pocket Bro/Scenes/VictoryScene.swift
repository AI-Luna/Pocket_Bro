//
//  VictoryScene.swift
//  Pocket Bro
//

import SpriteKit

class VictoryScene: BaseGameScene {
    private var confettiEmitter: SKEmitterNode?

    override var backgroundColor_: SKColor {
        SKColor(red: 0.1, green: 0.15, blue: 0.25, alpha: 1.0)
    }

    override func setupScene() {
        setupConfetti()
        setupContent()
        setupButtons()
    }

    private func setupConfetti() {
        // Create simple confetti effect
        let colors: [SKColor] = [.red, .yellow, .green, .blue, .purple, .orange]

        for _ in 0..<50 {
            let confetti = SKSpriteNode(color: colors.randomElement()!, size: CGSize(width: 8, height: 8))
            confetti.position = CGPoint(x: CGFloat.random(in: 0...size.width),
                                        y: size.height + 20)
            confetti.zPosition = 200
            addChild(confetti)

            let duration = Double.random(in: 2.0...4.0)
            let fall = SKAction.moveTo(y: -20, duration: duration)
            let rotate = SKAction.rotate(byAngle: .pi * CGFloat.random(in: 2...6), duration: duration)
            let sway = SKAction.sequence([
                SKAction.moveBy(x: 30, y: 0, duration: duration / 4),
                SKAction.moveBy(x: -60, y: 0, duration: duration / 2),
                SKAction.moveBy(x: 30, y: 0, duration: duration / 4)
            ])

            let group = SKAction.group([fall, rotate, sway])
            let sequence = SKAction.sequence([
                SKAction.wait(forDuration: Double.random(in: 0...2)),
                group,
                SKAction.removeFromParent()
            ])

            confetti.run(SKAction.repeatForever(SKAction.sequence([
                sequence,
                SKAction.run { [weak self] in
                    confetti.position = CGPoint(x: CGFloat.random(in: 0...(self?.size.width ?? 400)),
                                               y: (self?.size.height ?? 800) + 20)
                }
            ])))
        }
    }

    private func setupContent() {
        // Victory title
        let titleLabel = createLabel(text: "🦄 UNICORN STATUS! 🦄", fontSize: 32)
        titleLabel.fontColor = SKColor(red: 0.9, green: 0.7, blue: 1.0, alpha: 1.0)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - safeAreaInsets().top - 100)
        addChild(titleLabel)

        // Rainbow animation on title
        let colors: [SKColor] = [
            SKColor(red: 1, green: 0.4, blue: 0.4, alpha: 1),
            SKColor(red: 1, green: 0.8, blue: 0.4, alpha: 1),
            SKColor(red: 0.4, green: 1, blue: 0.4, alpha: 1),
            SKColor(red: 0.4, green: 0.8, blue: 1, alpha: 1),
            SKColor(red: 0.8, green: 0.4, blue: 1, alpha: 1)
        ]

        var colorActions: [SKAction] = []
        for color in colors {
            colorActions.append(SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: 0.3))
        }
        titleLabel.run(SKAction.repeatForever(SKAction.sequence(colorActions)))

        // Big unicorn
        let unicornLabel = SKLabelNode(text: "🦄")
        unicornLabel.fontSize = 120
        unicornLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 40)
        addChild(unicornLabel)

        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 20, duration: 0.5),
            SKAction.moveBy(x: 0, y: -20, duration: 0.5)
        ])
        unicornLabel.run(SKAction.repeatForever(bounce))

        // Congratulations message
        let congrats = createLabel(text: "You did it!", fontSize: 24)
        congrats.position = CGPoint(x: size.width / 2, y: size.height / 2 - 60)
        addChild(congrats)

        let message = """
        From a garage startup to a billion-dollar unicorn!
        You navigated the challenges of startup life
        and built something amazing.
        """

        let messageLabel = SKLabelNode(text: message)
        messageLabel.fontName = "Menlo"
        messageLabel.fontSize = 13
        messageLabel.fontColor = SKColor(white: 0.8, alpha: 1.0)
        messageLabel.numberOfLines = 4
        messageLabel.preferredMaxLayoutWidth = size.width - 60
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 130)
        addChild(messageLabel)

        // Final stats
        if let state = GameManager.shared.state {
            let statsText = """
            Founder: \(state.name) (\(state.archetype.rawValue))
            Total Actions: \(state.totalActionsPerformed)
            Events Experienced: \(state.eventsExperienced.count)
            Final Funding: $\(state.startup.funding)M
            """

            let statsLabel = SKLabelNode(text: statsText)
            statsLabel.fontName = "Menlo"
            statsLabel.fontSize = 11
            statsLabel.fontColor = SKColor(white: 0.6, alpha: 1.0)
            statsLabel.numberOfLines = 4
            statsLabel.horizontalAlignmentMode = .center
            statsLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 220)
            addChild(statsLabel)
        }
    }

    private func setupButtons() {
        // Play Again button
        let playAgainButton = PixelButtonNode(text: "New Journey", icon: "🚀", size: CGSize(width: 180, height: 50))
        playAgainButton.position = CGPoint(x: size.width / 2, y: safeAreaInsets().bottom + 100)

        playAgainButton.onTap = { [weak self] in
            GameManager.shared.deleteGame()
            self?.sceneManager?.presentScene(.onboarding)
        }

        addChild(playAgainButton)
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        alpha = 0
        run(SKAction.fadeIn(withDuration: 0.5))
    }
}
