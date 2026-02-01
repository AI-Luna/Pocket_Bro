//
//  ActionMenuScene.swift
//  Pocket Bro
//

import SpriteKit

class ActionMenuScene: BaseGameScene {
    private let category: ActionCategory
    private var actionButtons: [ActionButtonNode] = []
    private var backButton: PixelButtonNode!
    private var titleLabel: SKLabelNode!
    private var cooldownTimer: Timer?

    init(size: CGSize, sceneManager: SceneManager, category: ActionCategory) {
        self.category = category
        super.init(size: size, sceneManager: sceneManager)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupScene() {
        setupHeader()
        setupActionList()
        setupBackButton()
        startCooldownTimer()
    }

    private func setupHeader() {
        // Background
        let header = SKSpriteNode(color: SKColor(white: 0.1, alpha: 0.9),
                                   size: CGSize(width: size.width, height: 80))
        header.position = CGPoint(x: size.width / 2, y: size.height - safeAreaInsets().top - 40)
        header.zPosition = 50
        addChild(header)

        // Title
        titleLabel = createLabel(text: "\(category.emoji) \(category.displayName)", fontSize: 24)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - safeAreaInsets().top - 45)
        titleLabel.zPosition = 100
        addChild(titleLabel)
    }

    private func setupActionList() {
        let actions = ActionCatalog.shared.actions(for: category)
        let buttonHeight: CGFloat = 70
        let spacing: CGFloat = 12
        let startY = size.height - safeAreaInsets().top - 120

        for (index, action) in actions.enumerated() {
            let button = ActionButtonNode(action: action, size: CGSize(width: size.width - 40, height: buttonHeight))
            button.position = CGPoint(x: size.width / 2, y: startY - CGFloat(index) * (buttonHeight + spacing))
            button.zPosition = 10

            button.onTap = { [weak self] in
                self?.performAction(action)
            }

            addChild(button)
            actionButtons.append(button)

            // Add description below button
            let descLabel = SKLabelNode(text: action.description)
            descLabel.fontName = "Menlo"
            descLabel.fontSize = 10
            descLabel.fontColor = SKColor(white: 0.6, alpha: 1.0)
            descLabel.position = CGPoint(x: size.width / 2, y: button.position.y - buttonHeight / 2 - 8)
            descLabel.zPosition = 10
            addChild(descLabel)

            // Add effect preview
            let effectsText = formatEffects(action.effects)
            let effectsLabel = SKLabelNode(text: effectsText)
            effectsLabel.fontName = "Menlo"
            effectsLabel.fontSize = 9
            effectsLabel.fontColor = SKColor(white: 0.5, alpha: 1.0)
            effectsLabel.position = CGPoint(x: size.width / 2, y: button.position.y - buttonHeight / 2 - 20)
            effectsLabel.zPosition = 10
            addChild(effectsLabel)
        }

        updateButtonStates()
    }

    private func formatEffects(_ effects: [StatType: Int]) -> String {
        effects.map { stat, value in
            let sign = value >= 0 ? "+" : ""
            return "\(stat.emoji)\(sign)\(value)"
        }.joined(separator: " ")
    }

    private func setupBackButton() {
        backButton = PixelButtonNode(text: "← Back", size: CGSize(width: 100, height: 40))
        backButton.position = CGPoint(x: 70, y: safeAreaInsets().bottom + 40)
        backButton.zPosition = 100

        backButton.onTap = { [weak self] in
            self?.sceneManager?.popToMainGame()
        }

        addChild(backButton)
    }

    private func performAction(_ action: GameAction) {
        guard let result = GameManager.shared.performAction(action) else { return }

        // Show feedback
        showActionFeedback(result)

        // Check for minigame
        if let minigameType = action.triggersMinigame {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.sceneManager?.presentScene(.minigame(minigameType))
            }
        }

        updateButtonStates()
    }

    private func showActionFeedback(_ result: ActionResult) {
        let feedback = SKLabelNode(text: result.dialogue)
        feedback.fontName = "Menlo-Bold"
        feedback.fontSize = 16
        feedback.fontColor = .white
        feedback.position = CGPoint(x: size.width / 2, y: size.height / 2)
        feedback.zPosition = 200
        addChild(feedback)

        let fadeUp = SKAction.group([
            SKAction.moveBy(x: 0, y: 50, duration: 1.5),
            SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.fadeOut(withDuration: 0.5)
            ])
        ])

        feedback.run(SKAction.sequence([fadeUp, SKAction.removeFromParent()]))
    }

    private func updateButtonStates() {
        guard let state = GameManager.shared.state else { return }

        for button in actionButtons {
            let canPerform = button.action.canPerform(with: state)
            let cooldown = GameManager.shared.cooldownRemaining(for: button.action)

            button.updateCooldown(remaining: cooldown)

            if cooldown <= 0 {
                let reason = button.action.reasonCantPerform(with: state)
                button.updateAvailability(canPerform: canPerform, reason: reason)
            }
        }
    }

    // MARK: - Cooldown Timer

    private func startCooldownTimer() {
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateButtonStates()
        }
    }

    override func willMove(from view: SKView) {
        super.willMove(from: view)
        cooldownTimer?.invalidate()
        cooldownTimer = nil
    }

    // MARK: - Notifications

    override func handleGameStateUpdate(_ notification: Notification) {
        updateButtonStates()
    }
}
