//
//  MainGameScene.swift
//  Pocket Bro
//

import SpriteKit

class MainGameScene: BaseGameScene {
    private var broSprite: BroSpriteNode!
    private var statsBars: [StatType: StatsBarNode] = [:]
    private var categoryButtons: [CategoryButtonNode] = []
    private var stageIndicator: StageIndicatorNode!
    private var nameLabel: SKLabelNode!
    private var dialogueBubble: DialogueBubbleNode?

    override func setupScene() {
        setupBackground()
        setupCharacter()
        setupStatsDisplay()
        setupStageIndicator()
        setupActionButtons()
        updateUI()
    }

    private func setupBackground() {
        // Gradient-like background with layers
        let bgLayer1 = SKSpriteNode(color: SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0), size: size)
        bgLayer1.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bgLayer1.zPosition = -100
        addChild(bgLayer1)

        // Floor
        let floor = SKSpriteNode(color: SKColor(red: 0.15, green: 0.12, blue: 0.1, alpha: 1.0),
                                  size: CGSize(width: size.width, height: size.height * 0.3))
        floor.position = CGPoint(x: size.width / 2, y: floor.size.height / 2)
        floor.zPosition = -50
        addChild(floor)
    }

    private func setupCharacter() {
        broSprite = BroSpriteNode()
        broSprite.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        broSprite.zPosition = 10
        addChild(broSprite)

        nameLabel = createLabel(text: "", fontSize: 18)
        nameLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.62)
        nameLabel.zPosition = 10
        addChild(nameLabel)
    }

    private func setupStatsDisplay() {
        let statsToShow: [StatType] = [.energy, .health, .happiness, .social, .burnout]
        let startY = size.height - safeAreaInsets().top - 60
        let leftX: CGFloat = 30
        let spacing: CGFloat = 28

        for (index, statType) in statsToShow.enumerated() {
            let bar = StatsBarNode(statType: statType, width: 100)
            bar.position = CGPoint(x: leftX, y: startY - CGFloat(index) * spacing)
            bar.zPosition = 100
            addChild(bar)
            statsBars[statType] = bar
        }

        // Startup stats on the right
        let startupStats: [StatType] = [.funding, .product, .runway]
        let rightX = size.width - 30

        for (index, statType) in startupStats.enumerated() {
            let bar = StatsBarNode(statType: statType, width: 100)
            bar.position = CGPoint(x: rightX - 130, y: startY - CGFloat(index) * spacing)
            bar.zPosition = 100
            addChild(bar)
            statsBars[statType] = bar
        }
    }

    private func setupStageIndicator() {
        stageIndicator = StageIndicatorNode(width: size.width - 60)
        stageIndicator.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        stageIndicator.zPosition = 50
        addChild(stageIndicator)
    }

    private func setupActionButtons() {
        let categories = ActionCategory.allCases
        let buttonWidth: CGFloat = 80
        let spacing: CGFloat = 10
        let totalWidth = CGFloat(categories.count) * buttonWidth + CGFloat(categories.count - 1) * spacing
        let startX = (size.width - totalWidth) / 2 + buttonWidth / 2
        let buttonY = safeAreaInsets().bottom + 60

        for (index, category) in categories.enumerated() {
            let button = CategoryButtonNode(category: category)
            button.position = CGPoint(x: startX + CGFloat(index) * (buttonWidth + spacing), y: buttonY)
            button.zPosition = 100

            button.onTap = { [weak self] in
                self?.sceneManager?.pushActionMenu(category: category)
            }

            addChild(button)
            categoryButtons.append(button)
        }
    }

    private func updateUI() {
        guard let state = GameManager.shared.state else { return }

        nameLabel.text = "\(state.name) \(state.mood.emoji)"
        broSprite.update(with: state)

        // Update personal stats
        statsBars[.energy]?.setValue(state.stats.energy)
        statsBars[.health]?.setValue(state.stats.health)
        statsBars[.happiness]?.setValue(state.stats.happiness)
        statsBars[.social]?.setValue(state.stats.social)
        statsBars[.burnout]?.setValue(state.stats.burnout)

        // Update startup stats
        statsBars[.funding]?.setValue(state.startup.funding)
        statsBars[.product]?.setValue(state.startup.product)
        statsBars[.runway]?.setValue(state.startup.runway)

        // Update stage
        stageIndicator.update(stage: state.startup.stage,
                             funding: state.startup.funding,
                             product: state.startup.product)
    }

    // MARK: - Notifications

    override func handleGameStateUpdate(_ notification: Notification) {
        updateUI()
    }

    override func handleEventTrigger(_ notification: Notification) {
        guard let event = notification.object as? RandomEvent else { return }
        showEventBubble(event)
    }

    override func handleStageAdvance(_ notification: Notification) {
        stageIndicator.animateStageAdvance()
        broSprite.playHappyAnimation()

        if let stage = notification.object as? StartupStage {
            showDialogue("🎉 Advanced to \(stage.displayName)!")
        }
    }

    // MARK: - Dialogue

    func showDialogue(_ text: String, emoji: String? = nil) {
        dialogueBubble?.removeFromParent()

        let bubble = DialogueBubbleNode(maxWidth: 260)
        bubble.position = CGPoint(x: size.width / 2, y: broSprite.position.y + 100)
        bubble.zPosition = 200
        addChild(bubble)
        bubble.show(text: text, emoji: emoji)

        dialogueBubble = bubble
    }

    func showEventBubble(_ event: RandomEvent) {
        dialogueBubble?.removeFromParent()

        let bubble = DialogueBubbleNode(maxWidth: 300)
        bubble.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bubble.zPosition = 200
        addChild(bubble)
        bubble.showEvent(event)

        dialogueBubble = bubble

        if event.isPositive {
            broSprite.playHappyAnimation()
        } else {
            broSprite.playSadAnimation()
        }
    }
}
