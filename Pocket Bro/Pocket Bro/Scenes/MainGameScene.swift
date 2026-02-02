//
//  MainGameScene.swift
//  Pocket Bro
//

import SpriteKit

class MainGameScene: BaseGameScene, ActionSelectModalDelegate {

    // MARK: - UI Elements
    private var broSprite: BroSpriteNode!
    private var dialogueBubble: DialogueBubbleNode?
    private var activeModal: SKNode?

    // Stats bars
    private var statBars: [String: SKNode] = [:]

    // Bottom action buttons
    private var actionButtons: [SKNode] = []

    // Colors - LCD green theme
    private let lcdBackground = SKColor(red: 0.45, green: 0.55, blue: 0.45, alpha: 1.0)
    private let lcdScreenColor = SKColor(red: 0.52, green: 0.62, blue: 0.52, alpha: 1.0)
    private let lcdDarkColor = SKColor(red: 0.18, green: 0.22, blue: 0.18, alpha: 1.0)
    private let lcdLightColor = SKColor(red: 0.58, green: 0.68, blue: 0.58, alpha: 1.0)

    // Layout
    private var statsAreaHeight: CGFloat = 120
    private var buttonAreaHeight: CGFloat = 100
    private var gameAreaHeight: CGFloat = 0

    override func setupScene() {
        // Calculate layout
        let safeTop = safeAreaInsets().top
        let safeBottom = safeAreaInsets().bottom
        statsAreaHeight = 120 + safeTop
        buttonAreaHeight = 100 + safeBottom
        gameAreaHeight = size.height - statsAreaHeight - buttonAreaHeight

        setupBackground()
        setupStatsArea()
        setupCharacter()
        setupBottomButtons()
        updateUI()
    }

    // MARK: - Background

    private func setupBackground() {
        // Full background color
        let bg = SKSpriteNode(color: lcdBackground, size: size)
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = -100
        addChild(bg)

        // Screen area dimensions
        let screenPadding: CGFloat = 15
        let screenWidth = size.width - screenPadding * 2
        let screenHeight = gameAreaHeight - 20
        let screenY = buttonAreaHeight + screenHeight / 2 + 10

        // Screen border/frame
        let borderWidth: CGFloat = 6
        let screenBorder = SKShapeNode(rectOf: CGSize(width: screenWidth + borderWidth * 2, height: screenHeight + borderWidth * 2), cornerRadius: 8)
        screenBorder.fillColor = lcdDarkColor
        screenBorder.strokeColor = .clear
        screenBorder.position = CGPoint(x: size.width / 2, y: screenY)
        screenBorder.zPosition = -90
        addChild(screenBorder)

        // City background image from selected city
        let cityImageName = GameManager.shared.state?.city.imageName ?? City.sanFrancisco.imageName
        let texture = SKTexture(imageNamed: cityImageName)
        texture.filteringMode = .linear

        let citySprite = SKSpriteNode(texture: texture)

        // Scale to fill the screen area
        let scaleX = screenWidth / texture.size().width
        let scaleY = screenHeight / texture.size().height
        let scale = max(scaleX, scaleY)
        citySprite.setScale(scale)
        citySprite.position = CGPoint(x: size.width / 2, y: screenY)
        citySprite.zPosition = -85

        // Create crop node to clip to screen bounds
        let maskNode = SKShapeNode(rectOf: CGSize(width: screenWidth, height: screenHeight), cornerRadius: 4)
        maskNode.fillColor = .white
        maskNode.strokeColor = .clear
        maskNode.position = CGPoint(x: size.width / 2, y: screenY)

        let cropNode = SKCropNode()
        cropNode.maskNode = maskNode
        cropNode.addChild(citySprite)
        cropNode.zPosition = -85
        addChild(cropNode)
    }

    // MARK: - Stats Area

    private func setupStatsArea() {
        let statsY = size.height - safeAreaInsets().top - 50
        let stats: [(name: String, label: String)] = [
            ("energy", "ENERGY"),
            ("health", "HEALTH"),
            ("happiness", "HAPPY"),
            ("social", "SOCIAL")
        ]

        // Leave space for settings button on the right
        let availableWidth = size.width - 80
        let spacing = availableWidth / CGFloat(stats.count)
        let startX = 20 + spacing / 2

        for (index, stat) in stats.enumerated() {
            let x = startX + CGFloat(index) * spacing
            let statNode = createStatBar(name: stat.label)
            statNode.position = CGPoint(x: x, y: statsY)
            addChild(statNode)
            statBars[stat.name] = statNode
        }

        // Settings button (top right)
        let settingsButton = createSettingsButton()
        settingsButton.position = CGPoint(x: size.width - 35, y: statsY)
        settingsButton.name = "settingsButton"
        addChild(settingsButton)
    }

    private func createSettingsButton() -> SKNode {
        let button = SKNode()

        // Button background
        let bg = SKShapeNode(rectOf: CGSize(width: 36, height: 36), cornerRadius: 6)
        bg.fillColor = lcdDarkColor.withAlphaComponent(0.2)
        bg.strokeColor = lcdDarkColor.withAlphaComponent(0.4)
        bg.lineWidth = 1
        button.addChild(bg)

        // Gear icon (pixel art style)
        let gearIcon = drawGearIcon()
        button.addChild(gearIcon)

        return button
    }

    private func drawGearIcon() -> SKNode {
        let node = SKNode()
        let pixelSize: CGFloat = 2.5
        let color = lcdDarkColor

        // Simple 8x8 gear pattern
        let gear: [[Int]] = [
            [0,0,1,1,1,1,0,0],
            [0,1,1,0,0,1,1,0],
            [1,1,0,0,0,0,1,1],
            [1,0,0,1,1,0,0,1],
            [1,0,0,1,1,0,0,1],
            [1,1,0,0,0,0,1,1],
            [0,1,1,0,0,1,1,0],
            [0,0,1,1,1,1,0,0]
        ]

        let rows = gear.count
        let cols = gear[0].count
        let totalW = CGFloat(cols) * pixelSize
        let totalH = CGFloat(rows) * pixelSize

        for (rowIdx, row) in gear.enumerated() {
            for (colIdx, pixel) in row.enumerated() {
                if pixel == 1 {
                    let px = SKSpriteNode(color: color, size: CGSize(width: pixelSize, height: pixelSize))
                    let xPos = CGFloat(colIdx) * pixelSize - totalW / 2 + pixelSize / 2
                    let yPos = CGFloat(rows - 1 - rowIdx) * pixelSize - totalH / 2 + pixelSize / 2
                    px.position = CGPoint(x: xPos, y: yPos)
                    node.addChild(px)
                }
            }
        }

        return node
    }

    private func createStatBar(name: String) -> SKNode {
        let node = SKNode()

        // Label
        let label = SKLabelNode(text: name)
        label.fontName = PixelFont.name
        label.fontSize = 10
        label.fontColor = lcdDarkColor
        label.position = CGPoint(x: 0, y: 15)
        node.addChild(label)

        // Bar background
        let barWidth: CGFloat = 70
        let barHeight: CGFloat = 8

        let barBg = SKSpriteNode(color: lcdDarkColor.withAlphaComponent(0.4),
                                  size: CGSize(width: barWidth, height: barHeight))
        barBg.position = .zero
        barBg.name = "barBg"
        node.addChild(barBg)

        // Bar fill (pixel segments)
        let segments = 10
        let segmentWidth: CGFloat = (barWidth - 4) / CGFloat(segments)
        let segmentHeight: CGFloat = barHeight - 2
        let startX: CGFloat = -barWidth / 2 + 2 + segmentWidth / 2

        for i in 0..<segments {
            let segmentSize = CGSize(width: segmentWidth - 1, height: segmentHeight)
            let segment = SKSpriteNode(color: lcdDarkColor, size: segmentSize)
            let xPos: CGFloat = startX + CGFloat(i) * segmentWidth
            segment.position = CGPoint(x: xPos, y: 0)
            segment.name = "segment_\(i)"
            node.addChild(segment)
        }

        return node
    }

    // MARK: - Character

    private func setupCharacter() {
        let characterY = buttonAreaHeight + gameAreaHeight / 2 - 30

        broSprite = BroSpriteNode()
        broSprite.position = CGPoint(x: size.width / 2, y: characterY)
        broSprite.zPosition = 10
        broSprite.setScale(1.2)
        addChild(broSprite)

        startWalkingPatrol()
    }

    private func startWalkingPatrol() {
        let margin: CGFloat = 50
        let leftEdge = margin
        let rightEdge = size.width - margin
        let walkSpeed: CGFloat = 60 // points per second
        let pauseDuration: TimeInterval = 1.5
        // Helper to calculate duration based on distance
        func duration(from startX: CGFloat, to endX: CGFloat) -> TimeInterval {
            return Double(abs(endX - startX)) / Double(walkSpeed)
        }

        // Walk to right edge first (from center)
        let initialFaceRight = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.broSprite.xScale = abs(self.broSprite.xScale)
            self.broSprite.startWalkAnimation()
        }
        let initialMoveRight = SKAction.moveTo(x: rightEdge, duration: duration(from: size.width / 2, to: rightEdge))
        let initialPause = SKAction.run { [weak self] in
            self?.broSprite.startIdleAnimation()
        }

        // Repeating patrol: right edge -> left edge -> right edge
        let faceLeft = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.broSprite.xScale = -abs(self.broSprite.xScale)
            self.broSprite.startWalkAnimation()
        }
        let moveLeft = SKAction.moveTo(x: leftEdge, duration: duration(from: rightEdge, to: leftEdge))
        let pauseLeft = SKAction.run { [weak self] in
            self?.broSprite.startIdleAnimation()
        }

        let faceRight = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.broSprite.xScale = abs(self.broSprite.xScale)
            self.broSprite.startWalkAnimation()
        }
        let moveRight = SKAction.moveTo(x: rightEdge, duration: duration(from: leftEdge, to: rightEdge))
        let pauseRight = SKAction.run { [weak self] in
            self?.broSprite.startIdleAnimation()
        }

        let loopPatrol = SKAction.repeatForever(SKAction.sequence([
            faceLeft, moveLeft,
            pauseLeft, SKAction.wait(forDuration: pauseDuration),
            faceRight, moveRight,
            pauseRight, SKAction.wait(forDuration: pauseDuration)
        ]))

        let fullPatrol = SKAction.sequence([
            initialFaceRight, initialMoveRight,
            initialPause, SKAction.wait(forDuration: pauseDuration),
            loopPatrol
        ])

        broSprite.run(fullPatrol, withKey: "patrol")
    }

    // MARK: - Bottom Buttons

    private func setupBottomButtons() {
        let buttonY = buttonAreaHeight / 2 - safeAreaInsets().bottom / 2 + 10

        let categories: [ActionCategory] = [.feed, .work, .selfCare, .social]

        let buttonSize: CGFloat = 60
        let totalWidth = CGFloat(categories.count) * buttonSize + CGFloat(categories.count - 1) * 20
        let startX = (size.width - totalWidth) / 2 + buttonSize / 2

        for (index, category) in categories.enumerated() {
            let x = startX + CGFloat(index) * (buttonSize + 20)
            let icon = getIcon(for: category)
            let buttonNode = createPixelButton(icon: icon, size: buttonSize)
            buttonNode.position = CGPoint(x: x, y: buttonY)
            buttonNode.name = "category_\(category.rawValue)"
            addChild(buttonNode)
            actionButtons.append(buttonNode)
        }
    }

    private func createPixelButton(icon: [[Int]], size: CGFloat) -> SKNode {
        let button = SKNode()

        // Button background (rounded square, darker)
        let bg = SKShapeNode(rectOf: CGSize(width: size, height: size), cornerRadius: 8)
        bg.fillColor = lcdDarkColor.withAlphaComponent(0.3)
        bg.strokeColor = .clear
        button.addChild(bg)

        // Draw pixel icon
        let iconNode = drawPixelIcon(icon, pixelSize: 4, color: lcdDarkColor)
        button.addChild(iconNode)

        return button
    }

    private func drawPixelIcon(_ grid: [[Int]], pixelSize: CGFloat, color: SKColor) -> SKNode {
        let iconNode = SKNode()

        let rows = grid.count
        let cols = grid[0].count
        let totalWidth = CGFloat(cols) * pixelSize
        let totalHeight = CGFloat(rows) * pixelSize

        for (rowIndex, row) in grid.enumerated() {
            for (colIndex, pixel) in row.enumerated() {
                if pixel == 1 {
                    let pixelNode = SKSpriteNode(color: color, size: CGSize(width: pixelSize, height: pixelSize))
                    pixelNode.position = CGPoint(
                        x: CGFloat(colIndex) * pixelSize - totalWidth / 2 + pixelSize / 2,
                        y: CGFloat(rows - 1 - rowIndex) * pixelSize - totalHeight / 2 + pixelSize / 2
                    )
                    iconNode.addChild(pixelNode)
                }
            }
        }

        return iconNode
    }

    // MARK: - Pixel Icons

    private func getIcon(for category: ActionCategory) -> [[Int]] {
        switch category {
        case .feed:
            return PixelIcons.feed
        case .work:
            return PixelIcons.work
        case .selfCare:
            return PixelIcons.care
        case .social:
            return PixelIcons.social
        }
    }

    // MARK: - Update UI

    private func updateUI() {
        guard let state = GameManager.shared.state else { return }

        // Update stat bars
        updateStatBar("energy", value: state.stats.energy)
        updateStatBar("health", value: state.stats.health)
        updateStatBar("happiness", value: state.stats.happiness)
        updateStatBar("social", value: state.stats.social)

        // Update character
        broSprite.update(with: state)
    }

    private func updateStatBar(_ name: String, value: Int) {
        guard let bar = statBars[name] else { return }

        let normalizedValue = max(0, min(100, value))
        let filledSegments = normalizedValue / 10

        // Determine color based on value
        let barColor: SKColor
        if normalizedValue < 33 {
            // Low - Red
            barColor = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        } else if normalizedValue < 66 {
            // Medium - Orange
            barColor = SKColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 1.0)
        } else {
            // High - Green
            barColor = SKColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1.0)
        }

        for i in 0..<10 {
            if let segment = bar.childNode(withName: "segment_\(i)") as? SKSpriteNode {
                if i < filledSegments {
                    segment.color = barColor
                    segment.alpha = 1.0
                } else {
                    segment.color = lcdDarkColor
                    segment.alpha = 0.2
                }
            }
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Check if modal is active
        if let modal = activeModal as? ActionSelectModal {
            if modal.handleTouch(at: location) {
                return
            }
        }

        // Check settings button
        if let settingsButton = childNode(withName: "settingsButton"), settingsButton.contains(location) {
            animateButtonPress(settingsButton)
            sceneManager?.presentScene(.settings)
            return
        }

        // Check action buttons
        for button in actionButtons {
            if button.contains(location), let name = button.name, name.hasPrefix("category_") {
                let categoryName = String(name.dropFirst("category_".count))
                if let category = ActionCategory.allCases.first(where: { $0.rawValue == categoryName }) {
                    animateButtonPress(button)
                    showActionModal(for: category)
                    return
                }
            }
        }

        // Tap on character
        if broSprite.contains(location) {
            broSprite.playHappyAnimation()
        }
    }

    private func showActionModal(for category: ActionCategory) {
        let modal = ActionSelectModal(size: size, category: category)
        modal.delegate = self
        modal.position = CGPoint(x: size.width / 2, y: size.height / 2)
        modal.zPosition = 500
        addChild(modal)
        modal.show()
        activeModal = modal
    }

    // MARK: - ActionSelectModalDelegate

    func actionSelectModal(_ modal: ActionSelectModal, didSelect action: GameAction) {
        if let result = GameManager.shared.performAction(action) {
            showDialogue(result.dialogue, emoji: action.emoji)
            broSprite.playActionAnimation()

            // Check for minigame
            if let minigameType = action.triggersMinigame {
                run(SKAction.sequence([
                    SKAction.wait(forDuration: 1.0),
                    SKAction.run { [weak self] in
                        self?.sceneManager?.presentScene(.minigame(minigameType))
                    }
                ]))
            }
        }
    }

    func actionSelectModalDidClose(_ modal: ActionSelectModal) {
        activeModal = nil
    }

    private func animateButtonPress(_ button: SKNode) {
        let press = SKAction.sequence([
            SKAction.scale(to: 0.85, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        button.run(press)
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
        if let stage = notification.object as? StartupStage {
            showDialogue("Advanced to \(stage.displayName)!")
        }
        updateUI()
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

        let bubble = DialogueBubbleNode(maxWidth: 280)
        bubble.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
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
