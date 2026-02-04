//
//  LockInMinigameScene.swift
//  Pocket Bro
//

import SpriteKit

class LockInMinigameScene: BaseGameScene {
    private var timerLabel: SKLabelNode!
    private var progressBar: SKSpriteNode!
    private var progressFill: SKSpriteNode!
    private var focusMeter: SKSpriteNode!
    private var focusFill: SKSpriteNode!
    private var distractionNodes: [SKNode] = []

    private var timeRemaining: TimeInterval = 30
    private var focusLevel: CGFloat = 1.0
    private var productivityGained: Int = 0
    private var gameTimer: Timer?
    private var distractionTimer: Timer?
    private var isGameOver = false

    private let distractions: [(emoji: String, damage: CGFloat)] = [
        ("📱", 0.15),  // Phone notification
        ("🐦", 0.1),   // Twitter
        ("📧", 0.12),  // Email
        ("☕", 0.08),  // Coffee break temptation
        ("🛋️", 0.1),  // Couch calling
        ("🎮", 0.15),  // Gaming urge
        ("💬", 0.1),   // Slack message
    ]

    override func setupScene() {
        setupUI()
        startGame()
    }

    private func setupUI() {
        // Title
        let titleLabel = createLabel(text: "🔒 LOCK IN MODE", fontSize: 24)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - safeAreaInsets().top - 60)
        addChild(titleLabel)

        // Instructions
        let instrLabel = createLabel(text: "Tap distractions to dismiss them!", fontSize: 14)
        instrLabel.fontColor = SKColor(white: 0.6, alpha: 1.0)
        instrLabel.position = CGPoint(x: size.width / 2, y: size.height - safeAreaInsets().top - 90)
        addChild(instrLabel)

        // Timer
        timerLabel = createLabel(text: "30", fontSize: 48)
        timerLabel.position = CGPoint(x: size.width / 2, y: size.height - safeAreaInsets().top - 160)
        addChild(timerLabel)

        // Focus meter
        let focusLabel = createLabel(text: "Focus", fontSize: 12)
        focusLabel.position = CGPoint(x: size.width / 2, y: size.height - safeAreaInsets().top - 210)
        addChild(focusLabel)

        focusMeter = SKSpriteNode(color: SKColor(white: 0.2, alpha: 1.0),
                                   size: CGSize(width: size.width - 80, height: 20))
        focusMeter.position = CGPoint(x: size.width / 2, y: size.height - safeAreaInsets().top - 235)
        addChild(focusMeter)

        focusFill = SKSpriteNode(color: SKColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0),
                                  size: CGSize(width: size.width - 84, height: 16))
        focusFill.anchorPoint = CGPoint(x: 0, y: 0.5)
        focusFill.position = CGPoint(x: 42, y: size.height - safeAreaInsets().top - 235)
        addChild(focusFill)

        // Productivity counter
        let prodLabel = createLabel(text: "Productivity: 0", fontSize: 16)
        prodLabel.name = "productivity"
        prodLabel.position = CGPoint(x: size.width / 2, y: size.height - safeAreaInsets().top - 270)
        addChild(prodLabel)

        // Work area
        let workArea = SKSpriteNode(color: SKColor(white: 0.1, alpha: 0.5),
                                     size: CGSize(width: size.width - 40, height: size.height * 0.5))
        workArea.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        workArea.zPosition = -1
        addChild(workArea)

        // Laptop emoji in center
        let laptop = SKLabelNode(text: "💻")
        laptop.fontSize = 60
        laptop.position = CGPoint(x: size.width / 2, y: size.height * 0.35)
        addChild(laptop)
    }

    private func startGame() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.gameLoop()
        }

        distractionTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            self?.spawnDistraction()
        }
    }

    private func gameLoop() {
        guard !isGameOver else { return }

        timeRemaining -= 1
        timerLabel.text = "\(Int(timeRemaining))"

        // Gain productivity based on focus
        if focusLevel > 0.3 {
            let gain = Int(focusLevel * 5)
            productivityGained += gain

            if let prodLabel = childNode(withName: "productivity") as? SKLabelNode {
                prodLabel.text = "Productivity: \(productivityGained)"
            }
        }

        // Passive focus drain from existing distractions
        let distractionPenalty = CGFloat(distractionNodes.count) * 0.02
        focusLevel = max(0, focusLevel - distractionPenalty)
        updateFocusMeter()

        if timeRemaining <= 0 || focusLevel <= 0 {
            endGame()
        }
    }

    private func spawnDistraction() {
        guard !isGameOver, distractionNodes.count < 8 else { return }

        let distraction = distractions.randomElement()!

        let node = SKLabelNode(text: distraction.emoji)
        node.fontSize = 40
        node.name = "distraction"
        node.userData = ["damage": distraction.damage]

        // Random position in work area
        let margin: CGFloat = 50
        let x = CGFloat.random(in: margin...(size.width - margin))
        let y = CGFloat.random(in: (size.height * 0.15)...(size.height * 0.55))
        node.position = CGPoint(x: x, y: y)

        // Spawn animation
        node.setScale(0)
        node.alpha = 0

        let appear = SKAction.group([
            SKAction.scale(to: 1.0, duration: 0.3),
            SKAction.fadeIn(withDuration: 0.3)
        ])

        // Floating animation
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 10, duration: 0.5),
            SKAction.moveBy(x: 0, y: -10, duration: 0.5)
        ])

        node.run(appear)
        node.run(SKAction.repeatForever(float))

        addChild(node)
        distractionNodes.append(node)

        // Auto-damage if not dismissed
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run { [weak self, weak node] in
                if let node = node, node.parent != nil {
                    self?.applyDistraction(node)
                }
            }
        ]))
    }

    private func applyDistraction(_ node: SKNode) {
        guard let damage = node.userData?["damage"] as? CGFloat else { return }

        focusLevel = max(0, focusLevel - damage)
        updateFocusMeter()

        // Visual feedback
        let flash = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.5, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0, duration: 0.2)
        ])
        focusFill.run(flash)
    }

    private func updateFocusMeter() {
        let targetWidth = (size.width - 84) * focusLevel
        focusFill.run(SKAction.resize(toWidth: max(0, targetWidth), duration: 0.1))

        if focusLevel < 0.3 {
            focusFill.color = .red
        } else if focusLevel < 0.6 {
            focusFill.color = .orange
        } else {
            focusFill.color = SKColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !isGameOver else { return }
        let location = touch.location(in: self)

        // Check if tapped a distraction
        for node in distractionNodes {
            if node.contains(location) {
                dismissDistraction(node)
                return
            }
        }
    }

    private func dismissDistraction(_ node: SKNode) {
        distractionNodes.removeAll { $0 === node }

        // Satisfying dismiss animation
        let dismiss = SKAction.group([
            SKAction.scale(to: 1.5, duration: 0.15),
            SKAction.fadeOut(withDuration: 0.15)
        ])

        node.run(SKAction.sequence([dismiss, SKAction.removeFromParent()]))

        // Small focus recovery
        focusLevel = min(1.0, focusLevel + 0.05)
        updateFocusMeter()

        // Bonus productivity for quick dismiss
        productivityGained += 2
        if let prodLabel = childNode(withName: "productivity") as? SKLabelNode {
            prodLabel.text = "Productivity: \(productivityGained)"
        }
    }

    private func endGame() {
        isGameOver = true
        gameTimer?.invalidate()
        distractionTimer?.invalidate()

        // Clear remaining distractions
        for node in distractionNodes {
            node.removeFromParent()
        }
        distractionNodes.removeAll()

        let success = focusLevel > 0 && productivityGained >= 50

        // Result display
        let resultBg = SKSpriteNode(color: SKColor(white: 0, alpha: 0.8), size: size)
        resultBg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        resultBg.zPosition = 100
        addChild(resultBg)

        let resultTitle = success ? "🎯 Locked In!" : "😵 Lost Focus"
        let titleLabel = createLabel(text: resultTitle, fontSize: 32)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 80)
        titleLabel.zPosition = 101
        addChild(titleLabel)

        let scoreText = "Productivity Gained: \(productivityGained)"
        let scoreLabel = createLabel(text: scoreText, fontSize: 20)
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 20)
        scoreLabel.zPosition = 101
        addChild(scoreLabel)

        let bonusText = success ?
            "Bonus product progress!" :
            "Partial credit earned."
        let bonusLabel = createLabel(text: bonusText, fontSize: 14)
        bonusLabel.fontColor = SKColor(white: 0.7, alpha: 1.0)
        bonusLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 20)
        bonusLabel.zPosition = 101
        addChild(bonusLabel)

        // Continue button
        let continueButton = PixelButtonNode(text: "Continue", size: CGSize(width: 150, height: 50))
        continueButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 80)
        continueButton.zPosition = 101

        continueButton.onTap = { [weak self] in
            self?.sceneManager?.popToMainGame()
        }

        addChild(continueButton)
    }

    override func willMove(from view: SKView) {
        super.willMove(from: view)
        gameTimer?.invalidate()
        distractionTimer?.invalidate()
    }
}
