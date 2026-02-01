//
//  MainGameScene.swift
//  Pocket Bro
//

import SpriteKit

class MainGameScene: BaseGameScene, ActionSelectModalDelegate {

    // MARK: - UI Elements
    private var backgroundNode: SKSpriteNode!
    private var broSprite: BroSpriteNode!
    private var consoleNode: SKNode!
    private var lcdScreen: SKNode!
    private var dialogueBubble: DialogueBubbleNode?
    private var activeModal: SKNode?

    // Top bar buttons
    private var topBarButtons: [SKNode] = []

    // LCD Screen elements
    private var portraitNode: SKNode!
    private var nameLabel: SKLabelNode!
    private var ageLabel: SKLabelNode!
    private var moodHearts: SKNode!
    private var energyDots: SKNode!

    // Console buttons
    private var actionButtons: [SKNode] = []

    // Colors
    private let consoleColor = SKColor(red: 0.92, green: 0.91, blue: 0.88, alpha: 1.0)
    private let consoleShadow = SKColor(red: 0.75, green: 0.74, blue: 0.72, alpha: 1.0)
    private let lcdBackgroundColor = SKColor(red: 0.78, green: 0.82, blue: 0.73, alpha: 1.0)
    private let lcdTextColor = SKColor(red: 0.2, green: 0.25, blue: 0.2, alpha: 1.0)
    private let buttonColor = SKColor(red: 0.55, green: 0.25, blue: 0.45, alpha: 1.0)
    private let darkButtonColor = SKColor(red: 0.2, green: 0.22, blue: 0.25, alpha: 1.0)

    // Layout
    private var consoleHeight: CGFloat = 0
    private var gameAreaHeight: CGFloat = 0

    override func setupScene() {
        // Calculate layout
        consoleHeight = size.height * 0.42
        gameAreaHeight = size.height - consoleHeight

        setupBackground()
        setupTopBar()
        setupCharacter()
        setupConsole()
        updateUI()
    }

    // MARK: - Background & Game Area

    private func setupBackground() {
        // Create pixel art style background for garage/office
        let bgNode = SKNode()
        bgNode.position = CGPoint(x: size.width / 2, y: gameAreaHeight / 2 + consoleHeight)
        bgNode.zPosition = -100

        // Sky/Wall gradient
        let wallColor = SKColor(red: 0.85, green: 0.82, blue: 0.75, alpha: 1.0)
        let wall = SKSpriteNode(color: wallColor, size: CGSize(width: size.width, height: gameAreaHeight))
        bgNode.addChild(wall)

        // Window
        let windowWidth: CGFloat = 180
        let windowHeight: CGFloat = 160
        let windowFrame = SKSpriteNode(color: SKColor(red: 0.6, green: 0.55, blue: 0.45, alpha: 1.0),
                                        size: CGSize(width: windowWidth + 16, height: windowHeight + 16))
        windowFrame.position = CGPoint(x: 0, y: 40)
        bgNode.addChild(windowFrame)

        let windowGlass = SKSpriteNode(color: SKColor(red: 0.7, green: 0.85, blue: 0.95, alpha: 1.0),
                                        size: CGSize(width: windowWidth, height: windowHeight))
        windowGlass.position = CGPoint(x: 0, y: 40)
        bgNode.addChild(windowGlass)

        // Window dividers
        let vDivider = SKSpriteNode(color: SKColor.white, size: CGSize(width: 4, height: windowHeight))
        vDivider.position = CGPoint(x: 0, y: 40)
        bgNode.addChild(vDivider)

        let hDivider = SKSpriteNode(color: SKColor.white, size: CGSize(width: windowWidth, height: 4))
        hDivider.position = CGPoint(x: 0, y: 40)
        bgNode.addChild(hDivider)

        // Curtains
        let curtainColor = SKColor(red: 0.4, green: 0.55, blue: 0.35, alpha: 1.0)
        let leftCurtain = SKSpriteNode(color: curtainColor, size: CGSize(width: 35, height: windowHeight + 30))
        leftCurtain.position = CGPoint(x: -windowWidth/2 - 10, y: 40)
        bgNode.addChild(leftCurtain)

        let rightCurtain = SKSpriteNode(color: curtainColor, size: CGSize(width: 35, height: windowHeight + 30))
        rightCurtain.position = CGPoint(x: windowWidth/2 + 10, y: 40)
        bgNode.addChild(rightCurtain)

        // Desk
        let deskColor = SKColor(red: 0.6, green: 0.45, blue: 0.3, alpha: 1.0)
        let desk = SKSpriteNode(color: deskColor, size: CGSize(width: size.width * 0.7, height: 50))
        desk.position = CGPoint(x: 0, y: -gameAreaHeight/2 + 80)
        bgNode.addChild(desk)

        // Monitor on desk
        let monitorColor = SKColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1.0)
        let monitor = SKSpriteNode(color: monitorColor, size: CGSize(width: 80, height: 55))
        monitor.position = CGPoint(x: 80, y: -gameAreaHeight/2 + 120)
        bgNode.addChild(monitor)

        let monitorScreen = SKSpriteNode(color: SKColor(red: 0.3, green: 0.5, blue: 0.7, alpha: 1.0),
                                          size: CGSize(width: 70, height: 45))
        monitorScreen.position = CGPoint(x: 80, y: -gameAreaHeight/2 + 122)
        bgNode.addChild(monitorScreen)

        // Floor
        let floorColor = SKColor(red: 0.72, green: 0.58, blue: 0.42, alpha: 1.0)
        let floor = SKSpriteNode(color: floorColor, size: CGSize(width: size.width, height: 80))
        floor.position = CGPoint(x: 0, y: -gameAreaHeight/2 + 40)
        bgNode.addChild(floor)

        addChild(bgNode)
        backgroundNode = SKSpriteNode()
    }

    private func setupTopBar() {
        let topY = size.height - safeAreaInsets().top - 30
        let buttonSize: CGFloat = 36

        // Left side buttons
        let leftButtons = ["💡", "❤️", "🔋"]
        for (index, emoji) in leftButtons.enumerated() {
            let button = createTopBarButton(emoji: emoji, size: buttonSize)
            button.position = CGPoint(x: 30 + CGFloat(index) * (buttonSize + 12), y: topY)
            addChild(button)
            topBarButtons.append(button)
        }

        // Right side buttons
        let rightButtons = ["ℹ️", "⚙️"]
        for (index, emoji) in rightButtons.enumerated() {
            let button = createTopBarButton(emoji: emoji, size: buttonSize)
            button.position = CGPoint(x: size.width - 30 - CGFloat(index) * (buttonSize + 12), y: topY)
            addChild(button)
            topBarButtons.append(button)
        }
    }

    private func createTopBarButton(emoji: String, size: CGFloat) -> SKNode {
        let button = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: size, height: size), cornerRadius: 6)
        bg.fillColor = SKColor(white: 0.95, alpha: 0.9)
        bg.strokeColor = SKColor(white: 0.8, alpha: 1.0)
        bg.lineWidth = 2
        button.addChild(bg)

        let label = SKLabelNode(text: emoji)
        label.fontSize = size * 0.5
        label.verticalAlignmentMode = .center
        button.addChild(label)

        return button
    }

    // MARK: - Character

    private func setupCharacter() {
        broSprite = BroSpriteNode()
        broSprite.position = CGPoint(x: size.width / 2, y: consoleHeight + 60)
        broSprite.zPosition = 10
        broSprite.setScale(0.9)
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

    // MARK: - Console UI

    private func setupConsole() {
        consoleNode = SKNode()
        consoleNode.position = CGPoint(x: size.width / 2, y: consoleHeight / 2)
        consoleNode.zPosition = 50
        addChild(consoleNode)

        // Console body
        let bodyWidth = size.width
        let bodyHeight = consoleHeight + 40

        let body = SKShapeNode(rectOf: CGSize(width: bodyWidth, height: bodyHeight), cornerRadius: 30)
        body.fillColor = consoleColor
        body.strokeColor = .clear
        body.position = CGPoint(x: 0, y: 20)
        consoleNode.addChild(body)

        // Console top curve/edge
        let topEdge = SKShapeNode(rectOf: CGSize(width: bodyWidth - 40, height: 8), cornerRadius: 4)
        topEdge.fillColor = consoleShadow
        topEdge.strokeColor = .clear
        topEdge.position = CGPoint(x: 0, y: bodyHeight/2 + 12)
        consoleNode.addChild(topEdge)

        setupLCDScreen()
        setupConsoleButtons()
        setupBrandingLabel()
    }

    private func setupLCDScreen() {
        lcdScreen = SKNode()
        lcdScreen.position = CGPoint(x: 0, y: consoleHeight/2 - 80)
        consoleNode.addChild(lcdScreen)

        let screenWidth = size.width - 60
        let screenHeight: CGFloat = 110

        // Screen bezel
        let bezel = SKShapeNode(rectOf: CGSize(width: screenWidth + 12, height: screenHeight + 12), cornerRadius: 8)
        bezel.fillColor = SKColor(red: 0.6, green: 0.62, blue: 0.58, alpha: 1.0)
        bezel.strokeColor = .clear
        lcdScreen.addChild(bezel)

        // LCD background
        let lcd = SKShapeNode(rectOf: CGSize(width: screenWidth, height: screenHeight), cornerRadius: 4)
        lcd.fillColor = lcdBackgroundColor
        lcd.strokeColor = .clear
        lcdScreen.addChild(lcd)

        // Portrait area (left side)
        portraitNode = SKNode()
        portraitNode.position = CGPoint(x: -screenWidth/2 + 70, y: 0)
        lcdScreen.addChild(portraitNode)

        // Character portrait placeholder
        let portraitBg = SKShapeNode(rectOf: CGSize(width: 80, height: 70), cornerRadius: 4)
        portraitBg.fillColor = lcdBackgroundColor.withAlphaComponent(0.5)
        portraitBg.strokeColor = lcdTextColor.withAlphaComponent(0.3)
        portraitBg.lineWidth = 1
        portraitNode.addChild(portraitBg)

        // Portrait emoji
        let portraitEmoji = SKLabelNode(text: "👨‍💻")
        portraitEmoji.fontSize = 40
        portraitEmoji.position = CGPoint(x: 0, y: 5)
        portraitEmoji.verticalAlignmentMode = .center
        portraitEmoji.name = "portraitEmoji"
        portraitNode.addChild(portraitEmoji)

        // Name under portrait
        nameLabel = SKLabelNode(text: "Name")
        nameLabel.fontName = "Menlo-Bold"
        nameLabel.fontSize = 12
        nameLabel.fontColor = lcdTextColor
        nameLabel.position = CGPoint(x: 0, y: -42)
        nameLabel.name = "nameLabel"
        portraitNode.addChild(nameLabel)

        // Divider line
        let divider = SKSpriteNode(color: lcdTextColor.withAlphaComponent(0.3), size: CGSize(width: 2, height: 80))
        divider.position = CGPoint(x: -screenWidth/2 + 130, y: 0)
        lcdScreen.addChild(divider)

        // Stats area (right side)
        let statsX: CGFloat = 30
        let statsStartY: CGFloat = 28
        let statsSpacing: CGFloat = 28

        // Stage label
        let stageTitle = SKLabelNode(text: "Stage")
        stageTitle.fontName = "Menlo-Bold"
        stageTitle.fontSize = 13
        stageTitle.fontColor = lcdTextColor
        stageTitle.horizontalAlignmentMode = .left
        stageTitle.position = CGPoint(x: statsX, y: statsStartY)
        lcdScreen.addChild(stageTitle)

        let stageValue = SKLabelNode(text: "Garage")
        stageValue.fontName = "Menlo-Bold"
        stageValue.fontSize = 13
        stageValue.fontColor = lcdTextColor
        stageValue.horizontalAlignmentMode = .right
        stageValue.position = CGPoint(x: screenWidth/2 - 20, y: statsStartY)
        stageValue.name = "stageValue"
        lcdScreen.addChild(stageValue)

        // Mood row
        let moodTitle = SKLabelNode(text: "Mood")
        moodTitle.fontName = "Menlo-Bold"
        moodTitle.fontSize = 13
        moodTitle.fontColor = lcdTextColor
        moodTitle.horizontalAlignmentMode = .left
        moodTitle.position = CGPoint(x: statsX, y: statsStartY - statsSpacing)
        lcdScreen.addChild(moodTitle)

        moodHearts = SKNode()
        moodHearts.position = CGPoint(x: screenWidth/2 - 60, y: statsStartY - statsSpacing)
        lcdScreen.addChild(moodHearts)
        createHeartIndicators()

        // Energy row
        let energyTitle = SKLabelNode(text: "Energy")
        energyTitle.fontName = "Menlo-Bold"
        energyTitle.fontSize = 13
        energyTitle.fontColor = lcdTextColor
        energyTitle.horizontalAlignmentMode = .left
        energyTitle.position = CGPoint(x: statsX, y: statsStartY - statsSpacing * 2)
        lcdScreen.addChild(energyTitle)

        energyDots = SKNode()
        energyDots.position = CGPoint(x: screenWidth/2 - 60, y: statsStartY - statsSpacing * 2)
        lcdScreen.addChild(energyDots)
        createEnergyIndicators()
    }

    private func createHeartIndicators() {
        moodHearts.removeAllChildren()
        for i in 0..<3 {
            let heart = SKLabelNode(text: "♥")
            heart.fontName = "Menlo-Bold"
            heart.fontSize = 16
            heart.fontColor = lcdTextColor
            heart.horizontalAlignmentMode = .center
            heart.position = CGPoint(x: CGFloat(i) * 22, y: 0)
            heart.name = "heart_\(i)"
            moodHearts.addChild(heart)
        }
    }

    private func createEnergyIndicators() {
        energyDots.removeAllChildren()
        for i in 0..<3 {
            let dot = SKLabelNode(text: "●")
            dot.fontName = "Menlo-Bold"
            dot.fontSize = 14
            dot.fontColor = lcdTextColor
            dot.horizontalAlignmentMode = .center
            dot.position = CGPoint(x: CGFloat(i) * 22, y: 0)
            dot.name = "energy_\(i)"
            energyDots.addChild(dot)
        }
    }

    private func setupConsoleButtons() {
        // Category pill buttons (left side)
        let categories: [(String, ActionCategory)] = [
            ("Feed", .feed),
            ("Work", .work),
            ("Care", .selfCare),
            ("Social", .social)
        ]

        let pillWidth: CGFloat = 65
        let pillHeight: CGFloat = 28
        let pillSpacing: CGFloat = 8
        let pillStartX: CGFloat = -size.width/2 + 50
        let pillY: CGFloat = -20

        for (index, (title, category)) in categories.enumerated() {
            let pill = createPillButton(title: title, width: pillWidth, height: pillHeight)
            pill.position = CGPoint(x: pillStartX + CGFloat(index % 2) * (pillWidth + pillSpacing),
                                     y: pillY - CGFloat(index / 2) * (pillHeight + pillSpacing))
            pill.name = "category_\(category.rawValue)"
            consoleNode.addChild(pill)
            actionButtons.append(pill)
        }

        // Action buttons (right side) - Game Boy style
        let buttonRadius: CGFloat = 28
        let bigButtonX: CGFloat = size.width/2 - 80
        let bigButtonY: CGFloat = -30

        // A button (primary action)
        let aButton = createRoundButton(radius: buttonRadius, label: "A")
        aButton.position = CGPoint(x: bigButtonX + 35, y: bigButtonY - 20)
        aButton.name = "button_a"
        consoleNode.addChild(aButton)

        // B button (secondary/back)
        let bButton = createRoundButton(radius: buttonRadius, label: "B")
        bButton.position = CGPoint(x: bigButtonX - 20, y: bigButtonY + 15)
        bButton.name = "button_b"
        consoleNode.addChild(bButton)
    }

    private func createPillButton(title: String, width: CGFloat, height: CGFloat) -> SKNode {
        let button = SKNode()

        let bg = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: height/2)
        bg.fillColor = darkButtonColor
        bg.strokeColor = .clear
        button.addChild(bg)

        let label = SKLabelNode(text: title)
        label.fontName = "Menlo-Bold"
        label.fontSize = 11
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        button.addChild(label)

        return button
    }

    private func createRoundButton(radius: CGFloat, label: String) -> SKNode {
        let button = SKNode()

        // Shadow
        let shadow = SKShapeNode(circleOfRadius: radius)
        shadow.fillColor = buttonColor.withAlphaComponent(0.5)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 2, y: -2)
        button.addChild(shadow)

        // Main button
        let bg = SKShapeNode(circleOfRadius: radius)
        bg.fillColor = buttonColor
        bg.strokeColor = .clear
        button.addChild(bg)

        // Highlight
        let highlight = SKShapeNode(circleOfRadius: radius - 4)
        highlight.fillColor = buttonColor.lighter(by: 0.15)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -2, y: 2)
        button.addChild(highlight)

        // Label
        let labelNode = SKLabelNode(text: label)
        labelNode.fontName = "Menlo-Bold"
        labelNode.fontSize = 10
        labelNode.fontColor = .white.withAlphaComponent(0.6)
        labelNode.position = CGPoint(x: radius + 8, y: -radius - 8)
        button.addChild(labelNode)

        return button
    }

    private func setupBrandingLabel() {
        let branding = SKLabelNode(text: "Pocket Bro")
        branding.fontName = "Menlo"
        branding.fontSize = 12
        branding.fontColor = consoleShadow
        branding.position = CGPoint(x: 0, y: -consoleHeight/2 + 40)
        consoleNode.addChild(branding)
    }

    // MARK: - Update UI

    private func updateUI() {
        guard let state = GameManager.shared.state else { return }

        // Update portrait
        let emoji: String
        switch state.archetype {
        case .bro: emoji = "👨‍💻"
        case .gal: emoji = "👩‍💻"
        case .nonBinary: emoji = "🧑‍💻"
        }

        if let portraitEmoji = portraitNode.childNode(withName: "portraitEmoji") as? SKLabelNode {
            portraitEmoji.text = emoji
        }

        // Update name
        nameLabel.text = state.name

        // Update stage
        if let stageValue = lcdScreen.childNode(withName: "stageValue") as? SKLabelNode {
            stageValue.text = state.startup.stage.displayName
        }

        // Update mood hearts (based on happiness)
        let happinessLevel = min(3, max(0, state.stats.happiness / 34))
        for i in 0..<3 {
            if let heart = moodHearts.childNode(withName: "heart_\(i)") as? SKLabelNode {
                heart.text = i < happinessLevel ? "♥" : "♡"
            }
        }

        // Update energy dots
        let energyLevel = min(3, max(0, state.stats.energy / 34))
        for i in 0..<3 {
            if let dot = energyDots.childNode(withName: "energy_\(i)") as? SKLabelNode {
                dot.text = i < energyLevel ? "●" : "○"
            }
        }

        // Update character
        broSprite.update(with: state)
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

        // Check top bar buttons
        for button in topBarButtons {
            if button.contains(location) {
                animateButtonPress(button)
                // Settings button (gear icon)
                if button == topBarButtons.last {
                    sceneManager?.presentScene(.settings)
                    return
                }
                return
            }
        }

        let consoleLocation = touch.location(in: consoleNode)

        // Check category buttons
        for button in actionButtons {
            if button.contains(consoleLocation), let name = button.name, name.hasPrefix("category_") {
                let categoryName = String(name.dropFirst("category_".count))
                if let category = ActionCategory.allCases.first(where: { $0.rawValue == categoryName }) {
                    animateButtonPress(button)
                    showActionModal(for: category)
                    return
                }
            }
        }

        // Check A/B buttons
        if let aButton = consoleNode.childNode(withName: "button_a"), aButton.contains(consoleLocation) {
            animateButtonPress(aButton)
            // Quick action - show feed modal
            showActionModal(for: .feed)
            return
        }

        if let bButton = consoleNode.childNode(withName: "button_b"), bButton.contains(consoleLocation) {
            animateButtonPress(bButton)
            // Settings
            sceneManager?.presentScene(.settings)
            return
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
            SKAction.scale(to: 0.9, duration: 0.05),
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
        bubble.position = CGPoint(x: size.width / 2, y: broSprite.position.y + 80)
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

// MARK: - Color Extension

extension SKColor {
    func lighter(by percentage: CGFloat) -> SKColor {
        return self.adjust(by: abs(percentage))
    }

    func darker(by percentage: CGFloat) -> SKColor {
        return self.adjust(by: -abs(percentage))
    }

    private func adjust(by percentage: CGFloat) -> SKColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return SKColor(red: min(red + percentage, 1.0),
                       green: min(green + percentage, 1.0),
                       blue: min(blue + percentage, 1.0),
                       alpha: alpha)
    }
}
